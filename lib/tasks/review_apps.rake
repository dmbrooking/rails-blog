namespace :review_apps do
  desc 'create subdomain DNS record for Heroku review app'
  task :publish_dns do
    require 'cloudflare'
    require 'platform-api'

    staging_domain  = 'hedbergism.com'
    heroku_app_name = ENV['HEROKU_APP_NAME']
    subdomains      = %w[app duck oig]
    heroku_domain   = "#{heroku_app_name}.herokuapp.com"
    heroku_token    = ENV['HEROKU_PLATFORM_TOKEN']
    dns_records     = []
    type            = { type: 'CNAME' }

    dns_records << type.merge({ name: heroku_app_name, content: heroku_domain })
    subdomains.each do |sd|
      dns_records << type.merge({ name: "#{sd}.#{heroku_app_name}", content: heroku_domain })
    end

    heroku = PlatformAPI.connect_oauth heroku_token

    Cloudflare.connect(token: ENV['CLOUDFLARE_API_TOKEN']) do |connection|
      zone = connection.zones.find_by_name(staging_domain)

      [dns_records].each do |rec|
        zone.dns_records.create(rec[:type], rec[:name], rec[:content])
      rescue Cloudflare::RequestError => e
        next if e.message.include?('already exists')
      end
    end

    [dns_records].each do |rec|
      hostname = [rec[:name], staging_domain].join('.')
      heroku.domain.create(heroku_app_name, hostname:, sni_endpoint: nil)
      heroku.app.enable_acm(heroku_app_name)
    rescue Excon::Error::UnprocessableEntity => e
      next if e.response.body.include?('already exists')
    end
  end

  task :cleanup_dns do
    require 'cloudflare'
    require 'platform-api'

    staging_domain  = 'hedbergism.com'
    heroku_app_name = ENV['HEROKU_APP_NAME']
    domains         = [heroku_app_name, "app.#{heroku_app_name}", "duck.#{heroku_app_name}", "oig.#{heroku_app_name}"]

    Cloudflare.connect(token: ENV['CLOUDFLARE_API_TOKEN']) do |connection|
      zone = connection.zones.find_by_name(staging_domain)
      zone.dns_records.each do |record|
        [domains].each do |domain|
          hostname = [domain, staging_domain].join('.')
          record.delete if record.type == 'CNAME' && record.name == hostname
        end
      end
    end
  end
end

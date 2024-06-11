namespace :review_apps do
  desc 'create subdomain DNS record for Heroku review app'
  task :publish_dns do
    require 'cloudflare'
    require 'platform-api'

    staging_domain     = 'hedbergism.com'
    heroku_app_name    = ENV['HEROKU_APP_NAME']
    wildcard_subdomain = "*.#{heroku_app_name}"
    heroku_domain      = "#{heroku_app_name}.herokuapp.com"
    heroku_token       = ENV['HEROKU_PLATFORM_TOKEN']
    type               = { type: 'CNAME' }
    standard_sub_opts  = type.merge({ name: heroku_app_name, content: heroku_domain })
    wildcard_sub_opts  = type.merge({ name: wildcard_subdomain, content: heroku_domain })

    heroku = PlatformAPI.connect_oauth heroku_token

    Cloudflare.connect(token: ENV['CLOUDFLARE_API_TOKEN']) do |connection|
      zone = connection.zones.find_by_name(staging_domain)

      [standard_sub_opts, wildcard_sub_opts].each do |opts|
        zone.dns_records.create(opts[:type], opts[:name], opts[:content])
      rescue Cloudflare::RequestError => e
        next if e.message.include?('already exists')
      end
    end

    [heroku_app_name, wildcard_subdomain].each do |subdomain_type|
      hostname = [subdomain_type, staging_domain].join('.')
      heroku.domain.create(heroku_app_name, hostname:, sni_endpoint: nil)
    rescue Excon::Error::UnprocessableEntity => e
      next if e.response.body.include?('already exists')
    end
  end

  task :cleanup_dns do
    require 'cloudflare'
    require 'platform-api'

    staging_domain     = 'hedbergism.com'
    heroku_app_name    = ENV['HEROKU_APP_NAME']
    wildcard_subdomain = "*.#{heroku_app_name}"

    Cloudflare.connect(token: ENV['CLOUDFLARE_API_TOKEN']) do |connection|
      zone = connection.zones.find_by_name(staging_domain)
      zone.dns_records.each do |record|
        [heroku_app_name, wildcard_subdomain].each do |subdomain_type|
          hostname = [subdomain_type, staging_domain].join('.')
          record.delete if record.type == 'CNAME' && record.name == hostname
        end
      end
    end
  end
end

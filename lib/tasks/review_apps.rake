namespace :review_apps do
  desc 'create subdomain DNS record for Heroku review app'
  task :publish_dns do
    # require 'dnsimple'
    require 'platform-api'

    # STAGING_DOMAIN      = 'mystagingdomain.com'.freeze
    # DNSIMPLE_ACCOUNT_ID = .freeze
    heroku_app_name    = ENV['HEROKU_APP_NAME']
    subdomain          = heroku_app_name.match(/.*(pr-\d+)/).captures.first
    wildcard_subdomain = "*.#{subdomain}"
    heroku_domain      = "#{heroku_app_name}.herokuapp.com"
    heroku_token       = ENV['HEROKU_PLATFORM_TOKEN']
    type               = { type: 'CNAME' }
    standard_sub_opts  = type.merge({ name: subdomain, content: heroku_domain })
    wildcard_sub_opts  = type.merge({ name: wildcard_subdomain, content: heroku_domain })

    puts heroku_app_name
    puts subdomain
    puts wildcard_subdomain
    puts heroku_domain
    puts heroku_token
    puts type
    puts standard_sub_opts
    puts wildcard_sub_opts

    # client = Dnsimple::Client.new access_token: ENV['YOUR_ACCESS_TOKEN']
    # heroku = PlatformAPI.connect_oauth heroku_token

    # # Create records on DNSimple
    # [standard_sub_opts, wildcard_sub_opts].each do |opts|
    #   client.zones.create_record DNSIMPLE_ACCOUNT_ID, STAGING_DOMAIN, opts
    # end

    # # Let Heroku know about records
    # [subdomain, wildcard_subdomain].each do |subdomain_type|
    #   hostname = [subdomain_type, STAGING_DOMAIN].join('.')
    #   heroku.domain.create(heroku_app_name, hostname: hostname)
    # end
  end
end
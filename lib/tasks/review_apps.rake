# namespace :review_apps do
#   desc 'create subdomain DNS record for Heroku review app'
#   task :publish_dns do
#     require 'cloudflare'
#     require 'platform-api'

#     STAGING_DOMAIN     = 'hedbergism.com'.freeze
#     heroku_app_name    = ENV['HEROKU_APP_NAME']
#     wildcard_subdomain = "*.#{heroku_app_name}"
#     heroku_domain      = "#{heroku_app_name}.herokuapp.com"
#     heroku_token       = ENV['HEROKU_PLATFORM_TOKEN']
#     type               = { type: 'CNAME' }
#     standard_sub_opts  = type.merge({ name: heroku_app_name, content: heroku_domain })
#     wildcard_sub_opts  = type.merge({ name: wildcard_subdomain, content: heroku_domain })

#     # client = Dnsimple::Client.new access_token: ENV['YOUR_ACCESS_TOKEN']
#     heroku = PlatformAPI.connect_oauth heroku_token

#     # Create records on Cloudflare
#     Cloudflare.connect(key: ENV['CLOUDFLARE_API_TOKEN'], email: ENV['CLOUDFLARE_EMAIL']) do |connection|
# 	    # Get all available zones:
# 	    zones = connection.zones

# 	    # Get a specific zone:
# 	    zone = connection.zones.find_by_name(STAGING_DOMAIN)

# 	    # Get DNS records for a given zone:
# 	    dns_records = zone.dns_records

# 	    # Show some details of the DNS record:
# 	    dns_record = dns_records.first
# 	    puts dns_record.name

# 	    # Add a DNS record. Here we add an A record for `batman.example.com`:
# 	    # zone.dns_records.create('A', 'batman', '1.2.3.4', proxied: false)
#     end
#     # [standard_sub_opts, wildcard_sub_opts].each do |opts|
#     #   client.zones.create_record DNSIMPLE_ACCOUNT_ID, STAGING_DOMAIN, opts
#     # end

#     # Let Heroku know about records
#     [heroku_app_name, wildcard_subdomain].each do |subdomain_type|
#       hostname = [subdomain_type, STAGING_DOMAIN].join('.')
#       heroku.domain.create(heroku_app_name, hostname:)
#     end
#   end
# end
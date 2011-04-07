# Include hook code here
require 'active_support'
require 'geokit-rails'
require 'geo_regioning'

#Load the config
if File.exists?(File.join(RAILS_ROOT, 'config', 'geo_regioning.yml'))
  GeoRegioning::config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'geo_regioning.yml'))
else
  GeoRegioning::config = YAML.load_file(File.join(RAILS_ROOT, 'vendor', 'plugins','geo_regioning', 'lib', 'config', 'geo_regioning.yml'))
end

#set the Geokit options
Geokit::Geocoders::yahoo                  = GeoRegioning.config['geokit_options']['yahoo'] rescue false
Geokit::Geocoders::google                 = GeoRegioning.config['geokit_options']['google'] rescue false
Geokit::Geocoders::geocoder_us            = GeoRegioning.config['geokit_options']['geocoder_us'] rescue false
Geokit::Geocoders::geocoder_ca            = GeoRegioning.config['geokit_options']['geocoder_ca'] rescue false
Geokit::Geocoders::provider_order         = GeoRegioning.config['geokit_options']['provider_order'] rescue []
## there is timeout and request timeout depending on the gem version:
if Geokit::Geocoders.respond_to?(:request_timeout)
  Geokit::Geocoders::request_timeout        = GeoRegioning.config['geokit_options']['request_timeout'] rescue 3
else
  Geokit::Geocoders::timeout        = GeoRegioning.config['geokit_options']['request_timeout'] rescue 3
end

Geokit::default_units                     = GeoRegioning.config['geokit_options']['units'].to_sym rescue :miles
Geokit::default_formula                   = GeoRegioning.config['geokit_options']['formula'].to_sym rescue :sphere

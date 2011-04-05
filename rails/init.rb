# Include hook code here
require 'geokit-rails'
require 'geo_regioning'

#Load the config
if File.exists?(File.join(RAILS_ROOT, 'config', 'geo_regioning.yml'))
  GeoRegioning::config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'geo_regioning.yml'))
else
  GeoRegioning::config = YAML.load_file(File.join(RAILS_ROOT, 'vendor', 'plugins','geo_regioning', 'lib', 'config', 'geo_regioning.yml'))
end
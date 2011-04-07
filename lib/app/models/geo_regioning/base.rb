class GeoRegioning::Base < ActiveRecord::Base
  self.abstract_class = true
  include Geokit
  
  acts_as_mappable :distance_field_name => :distance,
                   :lat_column_name     => :geo_latitude,
                   :lng_column_name     => :geo_longitude,
                   :auto_geocode        => true

  def lat_long
    [self.geo_latitude, self.geo_longitude]
  end
end
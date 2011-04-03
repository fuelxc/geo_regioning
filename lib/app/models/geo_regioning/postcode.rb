class GeoRegioning::Postcode < GeoRegioning::Base
  set_table_name 'geo_regioning_postcodes'
  has_many :postcode_maps

  def address
    [self.country, self.code].compact.join(',')
  end

  def country
    self.postcode_maps.first.postcodable.country
  end

end

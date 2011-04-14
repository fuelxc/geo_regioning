class GeoRegioning::Postcode < GeoRegioning::Base
  set_table_name 'geo_regioning_postcodes'
  has_many :postcode_maps, :class_name => 'GeoRegioning::PostcodeMap', :dependent => :destroy
  belongs_to :parent, :class_name => 'GeoRegioning::Postcode'
  belongs_to :country, :class_name => 'GeoRegioning::Country'
  has_many :children, :class_name => 'GeoRegioning::Postcode'

  def address
    [self.code, self.country.try(:address)].compact.join(',')
  end

end

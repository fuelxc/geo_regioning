class GeoRegioning::Country < GeoRegioning::Base
  set_table_name 'geo_regioning_countries'
  has_many :levels, :as => :parent

  def address
    self.name || self.iso_3166
  end
end

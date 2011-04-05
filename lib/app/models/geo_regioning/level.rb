class GeoRegioning::Level < GeoRegioning::Base
  set_table_name 'geo_regioning_levels'

  has_many :postcode_maps, :as => :postcodable, :class_name => 'GeoRegioning::PostcodeMap'
  has_many :postcodes, :through => :postcode_maps, :class_name => 'GeoRegioning::Postcode'
  belongs_to :parent, :polymorphic => true
  has_many :children, :as => :parent, :class_name => 'GeoRegioning::Level'

  belongs_to :country, :class_name => 'GeoRegioning::Country'

  named_scope :of_depth, lambda{ |depth| { :conditions => { :depth => depth } } }

  validates_presence_of :country

  def address
    if GeoRegioning.config[self.country.iso_3166][self.depth]['hidden']
      self.parent.address
    else
      [(self.long_name || self.short_name), self.parent.address].compact.join(', ')
    end
  end

  def others_within(distance)
    self.class.find(:all, :origin => self.lat_long, :within => distance, :conditions => {:depth => self.depth})
  end

end

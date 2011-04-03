class GeoRegioning::Level < GeoRegioning::Base
  set_table_name 'geo_regioning_levels'

  has_many :postcode_maps, :as => :postcodable
  belongs_to :parent, :polymorphic => true
  has_many :children, :as => :parent, :class_name => 'Geography::Level'

  def address
    [self.parent.address, (self.long_name || self.short_name)].compact.join(',')
  end

  def country
    current_parent = self.parent
    while current_parent.parent
      current_parent = current_parent.parent
    end
    current_parent.address
  end
  
end

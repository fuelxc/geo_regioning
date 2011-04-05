class GeoRegioning::Country < GeoRegioning::Base
  set_table_name 'geo_regioning_countries'
  has_many :levels, :as => :parent, :dependent => :destroy
  has_many :postcodes, :dependent => :destroy
  has_many :levels, :class_name => 'GeoRegioning::Level'

  before_validation :upcase_iso_3166

  validates_presence_of :iso_3166
  validates_uniqueness_of :iso_3166

  @level_name_depth_map = {}

  def address
    self.iso_3166 || self.name
  end

  def level_name_depth_map
    @level_name_depth_map if @level_name_depth_map
    levels_hash = {}
    GeoRegioning.config[self.iso_3166].keys.map{|key| levels_hash[GeoRegioning.config[self.iso_3166][key]['name']] = key}
    @level_name_depth_map = levels_hash
  end

  def method_missing(method, *args, &block)
    if level_name_depth_map.keys.include?(method.to_s.singularize)
      self.levels.of_depth(level_name_depth_map[method.to_s.singularize])
    else
      super
    end
  end

  private
  def upcase_iso_3166
    self.iso_3166 = self.iso_3166.upcase
  end
  
end

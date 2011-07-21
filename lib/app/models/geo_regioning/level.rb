class GeoRegioning::Level < GeoRegioning::Base
  set_table_name 'geo_regioning_levels'
  
  acts_as_nested_set

  has_many :postcode_maps, :as => :postcodable, :class_name => 'GeoRegioning::PostcodeMap'
  has_many :postcodes, :through => :postcode_maps, :class_name => 'GeoRegioning::Postcode'
  belongs_to :parent, :class_name => 'GeoRegioning::Level', :counter_cache => true
  has_many :children, :class_name => 'GeoRegioning::Level', :foreign_key=> 'parent_id'

  belongs_to :country, :class_name => 'GeoRegioning::Country'

  named_scope :of_depth, lambda{ |depth| { :conditions => { :depth => depth } } }
  named_scope :descendents_deeper_for, lambda{ |deeper,parent| 
    subquery = self.send(:construct_finder_sql,
      :select => "geo_regioning_levels.id",
      :conditions => {:parent_id => parent.id}
    )
    (deeper - 1).times do
      subquery = self.send(:construct_finder_sql,
        :select => "geo_regioning_levels.id",
        :conditions => ["geo_regioning_levels.parent_id IN ( #{subquery} )", 'GeoRegioning::Level']
      )
    end
    {:conditions => "geo_regioning_levels.id IN ( #{subquery} )"}
  }
  
  named_scope :find_by_name_and_postcode, lambda{|name,postcode|
    {
      :joins => :postcodes,
      :conditions => ['(geo_regioning_levels.long_name = ? OR geo_regioning_levels.short_name = ?) AND geo_regioning_postcodes.code = ?', name, name, postcode]
    }
  }
  named_scope :find_by_postcode_and_name, lambda{|postcode,name|
    {
      :joins => :postcodes,
      :conditions => ['(geo_regioning_levels.long_name = ? OR geo_regioning_levels.short_name = ?) AND geo_regioning_postcodes.code = ?', name, name, postcode]
    }
  }
  
  named_scope :find_by_name, lambda{|name|
    {
      :conditions => ['(geo_regioning_levels.long_name = ? OR geo_regioning_levels.short_name = ?)', name, name]
    }
  }

  named_scope :find_by_code, lambda{|code|
    {
      :conditions => ['(geo_regioning_levels.long_code = ? OR geo_regioning_levels.short_code = ?)', code, code]
    }
  }

  named_scope :find_like_name, lambda{|name|
    name = "#{name}%"
    {
      :conditions => ['(geo_regioning_levels.long_name LIKE ? OR geo_regioning_levels.short_name LIKE ?)', name, name]
    }
  }
   
  named_scope :find_like_name_and_postcode, lambda{|name,postcode|
    name = "#{name}%"
    {:joins => :postcodes,
    :conditions => ["(geo_regioning_levels.long_name LIKE ? OR geo_regioning_levels.short_name LIKE ?) AND geo_regioning_postcodes.code = ?", name, name, postcode]}
  }
  
  named_scope :find_like_postcode_and_name, lambda{|postcode,name|
    name = "#{name}%"
    {:joins => :postcodes,
    :conditions => ["(geo_regioning_levels.long_name LIKE ? OR geo_regioning_levels.short_name LIKE ?) AND geo_regioning_postcodes.code = ?", name, name, postcode]}
  }
  
  named_scope :deepest, {:conditions => {:levels_count => 0}}

  before_validation :set_country
  before_validation :set_depth

  validates_presence_of :country
  validates_presence_of :depth

  @level_name_depth_map = {}

  def level_name_depth_map
    return unless self.country
    @level_name_depth_map if @level_name_depth_map
    levels_hash = {}
    GeoRegioning.config['country_definitions'][self.country.iso_3166].keys.select{|k| k.to_s.to_i == k}.map{|key| levels_hash[GeoRegioning.config['country_definitions'][self.country.iso_3166][key]['name']] = key}
    @level_name_depth_map = levels_hash
  end

  def to_s(display = :display)
    address(display)
  end

  def address(display = :geocode)
    if display.to_s.split(/and/).first.gsub(/_/,'') == 'self'
      #special case where we want self and a specific list
      levels = display.to_s.split(/and/).collect{|a| a.gsub(/_/,'')}
      #ditch self
      levels.shift
      value_method = GeoRegioning.config['country_definitions'][self.country.iso_3166][self.depth]["#{display.to_s}_value"] || GeoRegioning.config['country_definitions'][self.country.iso_3166][self.depth]["display_value"] || "name"
      address = [self.send(value_method)]
      (address + levels.collect{|a| self.send(a).address(:self)}).flatten.compact.join(', ')
    elsif GeoRegioning.config['country_definitions'][self.country.iso_3166][self.depth]["exclude_from_#{display.to_s}"]
      self.parent.try(:address, display) || self.country.address(display)
    else
      parent_address = self.parent.try(:address, display) || self.country.address(display)
      value_method = GeoRegioning.config['country_definitions'][self.country.iso_3166][self.depth]["#{display.to_s}_value"] || "name"
      [self.send(value_method), parent_address].compact.join(', ')
    end
  end

  def others_within(distance)
    self.class.find(:all, :origin => self.lat_long, :within => distance, :conditions => {:depth => self.depth})
  end
  
  def name 
    self.long_name || self.short_name
  end
  
  def code
    self.long_code || self.short_code
  end
  
  def toplevel
    num_calls = (self.country.toplevel_depth - self.depth)
    eval("self#{'.parent'*num_calls}")
  end

  private
  def set_depth
    if self.parent.respond_to?(:depth)
      self.depth = self.parent.depth + 1
    end
  end

  def set_country
    unless self.country 
      self.country = self.parent.try(:country)
    end
  end

  def method_missing(method, *args, &block)
      if level_name_depth_map.keys.include?(method.to_s.singularize)
      depth = level_name_depth_map[method.to_s.singularize]
      num_calls = (depth - self.depth).abs
      if self.depth < depth
        #children
        if num_calls == 1
          self.children
        else
          self.class.descendents_deeper_for(num_calls, self)
        end
      elsif self.depth > depth
        #parent
        return eval("self#{'.parent'*num_calls}")
      else
        super
      end
    else
      super
    end
  end
end

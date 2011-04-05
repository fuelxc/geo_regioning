class GeoRegioning::PostcodeMap < ActiveRecord::Base
  set_table_name 'geo_regioning_postcode_maps'
  belongs_to :postcode, :class_name => 'GeoRegioning::Postcode'
  belongs_to :postcodable, :polymorphic => true
end

ActiveRecord::Schema.define(:version => 0) do
  ##MODELS
  drop_table :geo_regioning_countries
  create_table :geo_regioning_countries, :force => true do |t|
    t.string :iso_3166, :length => 2, :null => false
    t.string :name
    t.string :iso_currency_code, :length => 3
    t.decimal   :geo_latitude,                            :precision => 12, :scale => 8
    t.decimal   :geo_longitude,                           :precision => 12, :scale => 8
    t.timestamps
  end
  add_index :geo_regioning_countries, :iso_3166, :name => 'country_iso_idx'
  add_index :geo_regioning_countries, [:geo_latitude,:geo_longitude], :name => 'country_geo_idx'

  drop_table :geo_regioning_levels
  create_table :geo_regioning_levels, :force => true do |t|
      t.string  :long_name
      t.string  :short_name, :length => 10
      t.string  :long_code
      t.string  :short_code, :length => 2
      t.integer :parent_type
      t.integer :parent_id
      t.integer :depth, :length => 2, :null => false, :default => 1
      t.decimal   :geo_latitude,                            :precision => 12, :scale => 8
      t.decimal   :geo_longitude,                           :precision => 12, :scale => 8
      t.timestamps
  end
  add_index :geo_regioning_levels, :parent_id, :name => 'level_parent_idx'
  add_index :geo_regioning_levels, [:geo_latitude,:geo_longitude], :name => 'level_geo_idx'

  drop_table :geo_regioning_postcodes
  create_table :geo_regioning_postcodes do |t|
    t.string  :code, :length => 12
    t.string  :parent_type
    t.integer :parent_id
    t.decimal   :geo_latitude,                            :precision => 12, :scale => 8
    t.decimal   :geo_longitude,                           :precision => 12, :scale => 8
    t.timestamps
  end
  add_index :geo_regioning_postcodes, :parent_id, :name => 'level_parent_idx'
  add_index :geo_regioning_postcodes, [:geo_latitude,:geo_longitude], :name => 'postcode_geo_idx'

  drop_table :geo_regioning_postcode_maps
  create_table :geo_regioning_postcode_maps do |t|
    t.integer   :postcode_id
    t.integer   :postcodable_id
    t.string    :postcodable_type
    t.timestamps
  end
  add_index  :geo_regioning_postcode_maps, :postcode_id, :name => 'postcode_idx'
  add_index  :geo_regioning_postcode_maps, [:postcodable_id, :postcodable_type], :name => 'postcodable_idx'
end
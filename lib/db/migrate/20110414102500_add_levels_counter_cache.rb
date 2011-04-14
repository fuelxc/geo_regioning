class AddLevelsCounterCache < ActiveRecord::Migration
  def self.up
    add_column :geo_regioning_levels, :levels_count, :integer, :default => 0
    add_column :geo_regioning_countries, :levels_count, :integer, :default => 0
    add_index  :geo_regioning_levels, :levels_count, :name => 'deepest_idx'
  end

  def self.down
    remove_index :geo_regioning_levels, :name => 'deepest_idx'
    remove_column :geo_regioning_countries, :levels_count
    remove_column :geo_regioning_levels, :levels_count
  end
end
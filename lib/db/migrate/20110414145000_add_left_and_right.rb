class AddLeftAndRight < ActiveRecord::Migration
  def self.up
    add_column :geo_regioning_levels, :lft, :integer, :null => false, :default => 0
    add_column :geo_regioning_levels, :rgt, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :geo_regioning_levels, :rgt
    remove_column :geo_regioning_levels, :lft
  end
end
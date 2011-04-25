class AddLeftAndRight < ActiveRecord::Migration
  def self.up
    add_column :geo_regioning_levels, :lft, :integer, :null => false, :default => 0
    add_column :geo_regioning_levels, :rgt, :integer, :null => false, :default => 0
    add_index  :geo_regioning_levels, [:lft,:rgt], :name => 'lft_rgt_idx'
  end

  def self.down
    remove_index :geo_regioning_levels, :name => :lft_rgt_idx
    remove_column :geo_regioning_levels, :rgt
    remove_column :geo_regioning_levels, :lft
  end
end
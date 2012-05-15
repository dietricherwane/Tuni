class AddTickingIdToFridayTickings < ActiveRecord::Migration
  def self.up
    add_column :friday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :friday_tickings, :ticking_id
  end
end

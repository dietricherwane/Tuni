class AddTickingIdToWednesdayTickings < ActiveRecord::Migration
  def self.up
    add_column :wednesday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :wednesday_tickings, :ticking_id
  end
end

class AddTickingIdToTuesdayTickings < ActiveRecord::Migration
  def self.up
    add_column :tuesday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :tuesday_tickings, :ticking_id
  end
end

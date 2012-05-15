class AddTickingIdToSaturdayTickings < ActiveRecord::Migration
  def self.up
    add_column :saturday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :saturday_tickings, :ticking_id
  end
end

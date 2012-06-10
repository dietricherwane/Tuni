class AddTickingIdToMondayTickings < ActiveRecord::Migration
  def self.up
    add_column :monday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :monday_tickings, :ticking_id
  end
end

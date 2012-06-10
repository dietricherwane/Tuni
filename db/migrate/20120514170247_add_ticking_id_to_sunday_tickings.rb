class AddTickingIdToSundayTickings < ActiveRecord::Migration
  def self.up
    add_column :sunday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :sunday_tickings, :ticking_id
  end
end

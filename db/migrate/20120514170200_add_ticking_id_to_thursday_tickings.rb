class AddTickingIdToThursdayTickings < ActiveRecord::Migration
  def self.up
    add_column :thursday_tickings, :ticking_id, :integer
  end

  def self.down
    remove_column :thursday_tickings, :ticking_id
  end
end

class RemoveCasualIdFromMondayTickings < ActiveRecord::Migration
  def self.up
    remove_column :monday_tickings, :casual_id
    remove_column :tuesday_tickings, :casual_id
    remove_column :wednesday_tickings, :casual_id
    remove_column :thursday_tickings, :casual_id
    remove_column :friday_tickings, :casual_id
    remove_column :saturday_tickings, :casual_id
    remove_column :sunday_tickings, :casual_id
  end

  def self.down
    add_column :monday_tickings, :casual_id, :integer
    add_column :tuesday_tickings, :casual_id, :integer
    add_column :wednesday_tickings, :casual_id, :integer
    add_column :thursday_tickings, :casual_id, :integer
    add_column :friday_tickings, :casual_id, :integer
    add_column :saturday_tickings, :casual_id, :integer
    add_column :sunday_tickings, :casual_id, :integer
  end
end

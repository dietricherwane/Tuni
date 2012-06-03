class RemoveWeekNumberFromWeekTickings < ActiveRecord::Migration
  def self.up
    remove_column :monday_tickings, :week_number
    remove_column :tuesday_tickings, :week_number
    remove_column :wednesday_tickings, :week_number
    remove_column :thursday_tickings, :week_number
    remove_column :friday_tickings, :week_number
    remove_column :saturday_tickings, :week_number
    remove_column :sunday_tickings, :week_number
  end

  def self.down
    add_column :monday_tickings, :week_number, :integer
    add_column :tuesday_tickings, :week_number, :integer
    add_column :wednesday_tickings, :week_number, :integer
    add_column :thursday_tickings, :week_number, :integer
    add_column :friday_tickings, :week_number, :integer
    add_column :saturday_tickings, :week_number, :integer
    add_column :sunday_tickings, :week_number, :integer
  end
end

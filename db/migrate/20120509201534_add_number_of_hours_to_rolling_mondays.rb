class AddNumberOfHoursToRollingMondays < ActiveRecord::Migration
  def self.up
    add_column :rolling_mondays, :number_of_hours, :integer
  end

  def self.down
    remove_column :rolling_mondays, :number_of_hours
  end
end

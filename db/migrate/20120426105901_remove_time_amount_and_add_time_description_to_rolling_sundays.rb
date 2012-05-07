class RemoveTimeAmountAndAddTimeDescriptionToRollingSundays < ActiveRecord::Migration
  def self.up
  	remove_column :rolling_sundays, :time_amount
  	add_column :rolling_sundays, :time_description, :string
  end

  def self.down
  	add_column :rolling_sundays, :time_amount, :integer
  	remove_column :rolling_sundays, :time_description
  end
end

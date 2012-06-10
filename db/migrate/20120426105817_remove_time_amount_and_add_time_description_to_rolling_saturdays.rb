class RemoveTimeAmountAndAddTimeDescriptionToRollingSaturdays < ActiveRecord::Migration
  def self.up
  	remove_column :rolling_saturdays, :time_amount
  	add_column :rolling_saturdays, :time_description, :string
  end

  def self.down
  	add_column :rolling_saturdays, :time_amount, :integer
  	remove_column :rolling_saturdays, :time_description
  end
end

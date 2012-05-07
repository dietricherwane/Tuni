class RemoveTimeAmountAndAddTimeDescriptionToRollingFridays < ActiveRecord::Migration
  def self.up
  	remove_column :rolling_fridays, :time_amount
  	add_column :rolling_fridays, :time_description, :string
  end

  def self.down
  	add_column :rolling_fridays, :time_amount, :integer
  	remove_column :rolling_fridays, :time_description
  end
end

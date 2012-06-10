class RemoveTimeAmountAndAddTimeDescriptionToRollingThursdays < ActiveRecord::Migration
  def self.up
  	remove_column :rolling_thursdays, :time_amount
  	add_column :rolling_thursdays, :time_description, :string
  end

  def self.down
  	add_column :rolling_thursdays, :time_amount, :integer
  	remove_column :rolling_thursdays, :time_description
  end
end

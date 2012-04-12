class AddDisabledToRollingTypes < ActiveRecord::Migration
  def self.up
    add_column :rolling_types, :disabled, :boolean
  end

  def self.down
    remove_column :rolling_types, :disabled
  end
end

class AddDelayBeforeReturnToCasualTypes < ActiveRecord::Migration
  def self.up
    add_column :casual_types, :delay_before_return, :integer
  end

  def self.down
    remove_column :casual_types, :delay_before_return
  end
end

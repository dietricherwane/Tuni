class CreateRollingSundays < ActiveRecord::Migration
  def self.up
    create_table :rolling_sundays do |t|
      t.integer :configuration_id
      t.integer :time_amount

      t.timestamps
    end
  end

  def self.down
    drop_table :rolling_sundays
  end
end

class CreateCasualTypes < ActiveRecord::Migration
  def self.up
    create_table :casual_types do |t|
      t.string :type_name
      t.integer :prime
      t.integer :hourly_rate
      t.integer :months_number
      t.integer :max_months_number

      t.timestamps
    end
  end

  def self.down
    drop_table :casual_types
  end
end

class CreateRollingTypes < ActiveRecord::Migration
  def self.up
    create_table :rolling_types do |t|
      t.string :rolling_type
      t.string :meaning
      t.integer :number_of_hours

      t.timestamps
    end
  end

  def self.down
    drop_table :rolling_types
  end
end

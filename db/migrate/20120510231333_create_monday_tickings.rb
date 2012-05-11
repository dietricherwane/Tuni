class CreateMondayTickings < ActiveRecord::Migration
  def self.up
    create_table :monday_tickings do |t|
      t.string :time_description
      t.integer :number_of_hours
      t.integer :line_id
      t.integer :team_id
      t.integer :casual_id
      t.integer :week_number

      t.timestamps
    end
  end

  def self.down
    drop_table :monday_tickings
  end
end

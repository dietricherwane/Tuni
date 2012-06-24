class CreateExtraHours < ActiveRecord::Migration
  def self.up
    create_table :extra_hours do |t|
      t.integer :week_number
      t.date :bonus_day
      t.boolean :authorized

      t.timestamps
    end
  end

  def self.down
    drop_table :extra_hours
  end
end

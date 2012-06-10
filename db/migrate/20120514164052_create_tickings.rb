class CreateTickings < ActiveRecord::Migration
  def self.up
    create_table :tickings do |t|
      t.integer :week_number

      t.timestamps
    end
  end

  def self.down
    drop_table :tickings
  end
end

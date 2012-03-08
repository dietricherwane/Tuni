class CreateWorkshops < ActiveRecord::Migration
  def self.up
    create_table :workshops do |t|
      t.string :workshop_name
      t.integer :direction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workshops
  end
end

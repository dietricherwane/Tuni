class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.integer :team_id
      t.integer :user_id
      t.integer :week_number

      t.timestamps
    end
  end

  def self.down
    drop_table :configurations
  end
end

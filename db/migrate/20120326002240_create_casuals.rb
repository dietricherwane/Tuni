class CreateCasuals < ActiveRecord::Migration
  def self.up
    create_table :casuals do |t|
      t.string :firstname
      t.string :lastname
      t.date :birthdate
      t.string :identifier
      t.integer :months_done
      t.boolean :expired
      t.boolean :retired_from_ticking

      t.timestamps
    end
  end

  def self.down
    drop_table :casuals
  end
end

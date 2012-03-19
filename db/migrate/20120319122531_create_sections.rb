class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :section_name

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end

class AddSectionIdToFridayTickings < ActiveRecord::Migration
  def self.up
    add_column :friday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :friday_tickings, :section_id
  end
end

class AddSectionIdToWednesdayTickings < ActiveRecord::Migration
  def self.up
    add_column :wednesday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :wednesday_tickings, :section_id
  end
end

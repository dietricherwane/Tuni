class AddSectionIdToTuesdayTickings < ActiveRecord::Migration
  def self.up
    add_column :tuesday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :tuesday_tickings, :section_id
  end
end

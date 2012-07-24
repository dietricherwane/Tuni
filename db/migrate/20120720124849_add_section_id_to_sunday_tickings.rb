class AddSectionIdToSundayTickings < ActiveRecord::Migration
  def self.up
    add_column :sunday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :sunday_tickings, :section_id
  end
end

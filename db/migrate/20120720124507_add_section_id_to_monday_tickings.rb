class AddSectionIdToMondayTickings < ActiveRecord::Migration
  def self.up
    add_column :monday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :monday_tickings, :section_id
  end
end

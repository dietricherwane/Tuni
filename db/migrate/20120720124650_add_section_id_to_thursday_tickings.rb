class AddSectionIdToThursdayTickings < ActiveRecord::Migration
  def self.up
    add_column :thursday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :thursday_tickings, :section_id
  end
end

class AddSectionIdToSaturdayTickings < ActiveRecord::Migration
  def self.up
    add_column :saturday_tickings, :section_id, :integer
  end

  def self.down
    remove_column :saturday_tickings, :section_id
  end
end

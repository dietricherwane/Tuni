class AddSectionIdToLines < ActiveRecord::Migration
  def self.up
    add_column :lines, :section_id, :integer
  end

  def self.down
    remove_column :lines, :section_id
  end
end

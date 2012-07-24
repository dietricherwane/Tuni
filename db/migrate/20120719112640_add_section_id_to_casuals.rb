class AddSectionIdToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :section_id, :integer
  end

  def self.down
    remove_column :casuals, :section_id
  end
end

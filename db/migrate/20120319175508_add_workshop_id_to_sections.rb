class AddWorkshopIdToSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :workshop_id, :integer
  end

  def self.down
    remove_column :sections, :workshop_id
  end
end

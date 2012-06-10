class AddWorkshopIdToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :workshop_id, :integer
  end

  def self.down
    remove_column :teams, :workshop_id
  end
end

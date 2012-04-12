class AddEnabledToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :enabled, :boolean
  end

  def self.down
    remove_column :teams, :enabled
  end
end

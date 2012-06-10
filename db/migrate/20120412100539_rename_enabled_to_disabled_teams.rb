class RenameEnabledToDisabledTeams < ActiveRecord::Migration
  def self.up
  	rename_column :teams, :enabled, :disabled
  end

  def self.down
  end
end

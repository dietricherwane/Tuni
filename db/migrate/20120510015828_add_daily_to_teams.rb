class AddDailyToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :daily, :boolean
  end

  def self.down
    remove_column :teams, :daily
  end
end

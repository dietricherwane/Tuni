class AddPreviousTeamToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :previous_team, :integer
  end

  def self.down
    remove_column :casuals, :previous_team
  end
end

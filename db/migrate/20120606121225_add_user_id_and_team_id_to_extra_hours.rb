class AddUserIdAndTeamIdToExtraHours < ActiveRecord::Migration
  def self.up
    add_column :extra_hours, :user_id, :integer
    add_column :extra_hours, :team_id, :integer
  end

  def self.down
    remove_column :extra_hours, :team_id
    remove_column :extra_hours, :user_id
  end
end

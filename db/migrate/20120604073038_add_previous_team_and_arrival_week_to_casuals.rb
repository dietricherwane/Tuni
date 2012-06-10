class AddPreviousTeamAndArrivalWeekToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :previous_week, :integer
    add_column :casuals, :arrival_week, :integer
  end

  def self.down
    remove_column :casuals, :arrival_week
    remove_column :casuals, :previous_week
  end
end

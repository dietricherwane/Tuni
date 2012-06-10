class RemoveArrivalWeekFromCasuals < ActiveRecord::Migration
  def self.up
    remove_column :casuals, :arrival_week
  end

  def self.down
    add_column :casuals, :arrival_week, :integer
  end
end

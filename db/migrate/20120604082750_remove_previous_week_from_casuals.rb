class RemovePreviousWeekFromCasuals < ActiveRecord::Migration
  def self.up
    remove_column :casuals, :previous_week
  end

  def self.down
    add_column :casuals, :previous_week, :integer
  end
end

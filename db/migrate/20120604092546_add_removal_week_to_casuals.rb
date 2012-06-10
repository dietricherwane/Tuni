class AddRemovalWeekToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :removal_week, :integer
  end

  def self.down
    remove_column :casuals, :removal_week
  end
end

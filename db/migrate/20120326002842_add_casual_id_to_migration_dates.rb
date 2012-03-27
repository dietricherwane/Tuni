class AddCasualIdToMigrationDates < ActiveRecord::Migration
  def self.up
    add_column :migration_dates, :casual_id, :integer
  end

  def self.down
    remove_column :migration_dates, :casual_id
  end
end

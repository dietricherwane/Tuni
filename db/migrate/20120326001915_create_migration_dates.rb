class CreateMigrationDates < ActiveRecord::Migration
  def self.up
    create_table :migration_dates do |t|
      t.date :entrance_date
      t.date :exit_date

      t.timestamps
    end
  end

  def self.down
    drop_table :migration_dates
  end
end

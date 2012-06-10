class AddCompanyIdAndCityIdAndCasualTypeIdAndMigrationDateIdAndWorkshopIdAndTeamIdToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :company_id, :integer
    add_column :casuals, :city_id, :integer
    add_column :casuals, :casual_type_id, :integer
    add_column :casuals, :migration_date_id, :integer
    add_column :casuals, :workshop_id, :integer
    add_column :casuals, :team_id, :integer
  end

  def self.down
    remove_column :casuals, :team_id
    remove_column :casuals, :workshop_id
    remove_column :casuals, :migration_date_id
    remove_column :casuals, :casual_type_id
    remove_column :casuals, :city_id
    remove_column :casuals, :company_id
  end
end

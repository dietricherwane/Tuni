class AddMaxNumberOfCasualsToWorkshops < ActiveRecord::Migration
  def self.up
    add_column :workshops, :max_number_of_casuals, :integer
  end

  def self.down
    remove_column :workshops, :max_number_of_casuals
  end
end

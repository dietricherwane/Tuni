class AddMaxNumberOfCasualsToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :max_number_of_casuals, :integer
  end

  def self.down
    remove_column :teams, :max_number_of_casuals
  end
end

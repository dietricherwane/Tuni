class AddNumberOfOperatorsToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :number_of_operators, :integer
  end

  def self.down
    remove_column :teams, :number_of_operators
  end
end

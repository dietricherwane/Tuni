class AddDefaultSectionToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :default_section, :integer
  end

  def self.down
    remove_column :teams, :default_section
  end
end

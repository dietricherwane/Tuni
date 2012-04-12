class AddMaxNumberOfCasualsToLines < ActiveRecord::Migration
  def self.up
    add_column :lines, :max_number_of_casuals, :integer
  end

  def self.down
    remove_column :lines, :max_number_of_casuals
  end
end

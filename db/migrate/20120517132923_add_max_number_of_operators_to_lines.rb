class AddMaxNumberOfOperatorsToLines < ActiveRecord::Migration
  def self.up
    add_column :lines, :max_number_of_operators, :integer
  end

  def self.down
    remove_column :lines, :max_number_of_operators
  end
end

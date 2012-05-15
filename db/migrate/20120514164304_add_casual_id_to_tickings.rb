class AddCasualIdToTickings < ActiveRecord::Migration
  def self.up
    add_column :tickings, :casual_id, :integer
  end

  def self.down
    remove_column :tickings, :casual_id
  end
end

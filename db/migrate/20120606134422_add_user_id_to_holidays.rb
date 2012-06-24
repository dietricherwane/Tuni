class AddUserIdToHolidays < ActiveRecord::Migration
  def self.up
    add_column :holidays, :user_id, :integer
  end

  def self.down
    remove_column :holidays, :user_id
  end
end

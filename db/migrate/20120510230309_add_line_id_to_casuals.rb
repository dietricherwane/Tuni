class AddLineIdToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :line_id, :integer
  end

  def self.down
    remove_column :casuals, :line_id
  end
end

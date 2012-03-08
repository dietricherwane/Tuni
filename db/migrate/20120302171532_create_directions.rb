# -*- encoding : utf-8 -*-
class CreateDirections < ActiveRecord::Migration
  def self.up
    create_table :directions do |t|
      t.string :direction_name

      t.timestamps
    end
  end

  def self.down
    drop_table :directions
  end
end

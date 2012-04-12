class RenameMeaningToDescriptionRollingTypes < ActiveRecord::Migration
  def self.up
  	rename_column :rolling_types, :meaning, :description
  end

  def self.down
  end
end

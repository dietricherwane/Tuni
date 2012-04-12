class RenameRollingTypeToTypeNameRollingTypes < ActiveRecord::Migration
  def self.up
  	rename_column :rolling_types, :rolling_type, :type_name
  end

  def self.down
  end
end

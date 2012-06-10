class CreateConfigurationsLines < ActiveRecord::Migration
  def self.up
  	create_table :configurations_lines, :id => false do |t|
			t.references :configuration
			t.references :line
		end
  end

  def self.down
  	drop_table :configurations_lines
  end
end

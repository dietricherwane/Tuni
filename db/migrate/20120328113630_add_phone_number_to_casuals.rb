class AddPhoneNumberToCasuals < ActiveRecord::Migration
  def self.up
    add_column :casuals, :phone_number, :string
  end

  def self.down
    remove_column :casuals, :phone_number
  end
end

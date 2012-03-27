class Casual < ActiveRecord::Base
	belongs_to :workshop
	belongs_to :team
	belongs_to :company
	belongs_to :city
	belongs_to :casual_type
	has_many :migration_dates
end

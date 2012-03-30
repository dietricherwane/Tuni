class Casual < ActiveRecord::Base
	belongs_to :workshop
	belongs_to :team
	belongs_to :company
	belongs_to :city
	belongs_to :casual_type
	has_many :migration_dates
	# lié à la création des Casual: migration_date
	default_scope order('casuals.created_at DESC', 'casuals.firstname ASC', 'casuals.lastname ASC')
end

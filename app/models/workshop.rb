class Workshop < ActiveRecord::Base
	default_scope :order => 'workshop_name ASC'
	has_many :teams
	belongs_to :direction
end

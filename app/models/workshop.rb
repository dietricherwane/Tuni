class Workshop < ActiveRecord::Base
	default_scope :order => 'workshop_name ASC'
	has_many :teams
	has_many :sections
	belongs_to :direction
end

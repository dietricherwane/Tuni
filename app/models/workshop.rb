class Workshop < ActiveRecord::Base
	default_scope :order => 'workshop_name ASC'
	has_many :teams
	has_many :sections
	has_many :casuals
	belongs_to :direction
end

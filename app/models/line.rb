class Line < ActiveRecord::Base
	belongs_to :section
	has_many :casuals
	has_and_belongs_to_many :configurations
	has_many :monday_tickings
	has_many :tuesday_tickings
	has_many :wednesday_tickings
	has_many :thursday_tickings
	has_many :friday_tickings
	has_many :saturday_tickings
	has_many :sunday_tickings
end

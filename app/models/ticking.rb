class Ticking < ActiveRecord::Base
	belongs_to :casual
	has_one :monday_ticking
	has_one :tuesday_ticking
	has_one :wednesday_ticking
	has_one :thursday_ticking
	has_one :friday_ticking
	has_one :saturday_ticking
	has_one :sunday_ticking
end

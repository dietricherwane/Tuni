class Configuration < ActiveRecord::Base
	belongs_to :team
	belongs_to :user
	has_and_belongs_to_many :lines
	has_many :rolling_mondays
	has_many :rolling_tuesdays
	has_many :rolling_wednesdays
	has_many :rolling_thursdays
	has_many :rolling_fridays
	has_many :rolling_saturdays
	has_many :rolling_sundays
end

class Configuration < ActiveRecord::Base
	belongs_to :team
	belongs_to :user
	has_and_belongs_to_many :lines
	has_one :rolling_monday, :dependent => :destroy
	has_one :rolling_tuesday, :dependent => :destroy
	has_one :rolling_wednesday, :dependent => :destroy
	has_one :rolling_thursday, :dependent => :destroy
	has_one :rolling_friday, :dependent => :destroy
	has_one :rolling_saturday, :dependent => :destroy
	has_one :rolling_sunday, :dependent => :destroy
end

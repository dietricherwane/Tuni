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
	
	def count_rolling_days(configuration)
  	@counter = 0
  	@counter += 1 unless configuration.rolling_monday.eql?(nil)
  	@counter += 1 unless configuration.rolling_tuesday.eql?(nil)
  	@counter += 1 unless configuration.rolling_wednesday.eql?(nil)
  	@counter += 1 unless configuration.rolling_thursday.eql?(nil)
  	@counter += 1 unless configuration.rolling_friday.eql?(nil)
  	@counter += 1 unless configuration.rolling_saturday.eql?(nil)
  	@counter += 1 unless configuration.rolling_sunday.eql?(nil)
  	@counter
  end
	
end

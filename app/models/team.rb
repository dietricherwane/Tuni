class Team < ActiveRecord::Base
	has_many :casuals
	has_many :configurations
	belongs_to :workshop
end

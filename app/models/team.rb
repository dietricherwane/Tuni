class Team < ActiveRecord::Base
	has_many :casuals
	belongs_to :workshop
end

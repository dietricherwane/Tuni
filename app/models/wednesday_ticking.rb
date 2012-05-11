class WednesdayTicking < ActiveRecord::Base
	belongs_to :casual
	belongs_to :line
	belongs_to :team
end

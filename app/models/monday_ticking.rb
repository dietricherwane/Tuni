class MondayTicking < ActiveRecord::Base
	belongs_to :ticking
	belongs_to :line
	belongs_to :team
end

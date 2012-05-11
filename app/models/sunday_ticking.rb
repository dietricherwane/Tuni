class SundayTicking < ActiveRecord::Base
	belongs_to :casual
	belongs_to :line
	belongs_to :team
end

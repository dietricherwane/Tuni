class Line < ActiveRecord::Base
	belongs_to :section
	has_and_belongs_to_many :configurations
end

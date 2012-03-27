class City < ActiveRecord::Base
	validates_uniqueness_of :city_name, :short_name
	default_scope :order => 'city_name ASC'
	has_many :casuals
end

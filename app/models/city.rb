class City < ActiveRecord::Base
	#validates_uniqueness_of :city_name, :short_name
	validates :city_name, :length => { :in => 2..10 }, :presence => true
	validates :short_name, :length => { :in => 2..10 }, :presence => true
	default_scope :order => 'city_name ASC'
	has_many :casuals
end

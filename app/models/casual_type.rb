class CasualType < ActiveRecord::Base
	validates_uniqueness_of :type_name
	default_scope :order => 'type_name ASC'
	has_many :casuals
end

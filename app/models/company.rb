class Company < ActiveRecord::Base
	validates_uniqueness_of :company_name
	default_scope :order => 'company_name ASC'
	has_many :casuals
end

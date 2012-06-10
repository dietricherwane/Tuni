class Section < ActiveRecord::Base
	default_scope :order => 'section_name ASC'
	belongs_to :workshop
	has_many :lines
end

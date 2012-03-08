# -*- encoding : utf-8 -*-
class Direction < ActiveRecord::Base
	default_scope :order => 'id ASC'
	has_many :workshops#, :order => 'published_at DESC'
end

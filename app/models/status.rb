# -*- encoding : utf-8 -*-
class Status < ActiveRecord::Base
	default_scope :order => 'id ASC'
	has_many :users
end

class Holiday < ActiveRecord::Base
	default_scope order('holiday DESC')
end

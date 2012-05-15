class Casual < ActiveRecord::Base
	belongs_to :workshop
	belongs_to :team
	belongs_to :company
	belongs_to :city
	belongs_to :casual_type
	has_many :migration_dates
	belongs_to :line
	has_many :tickings
	
	# lié à la création des Casual: migration_date
	default_scope order('casuals.created_at DESC', 'casuals.firstname ASC', 'casuals.lastname ASC')
	
	def casual_status(casual)
  	@value = ""
  	if ((casual.team_id != nil) && (casual.retired_from_ticking != true) && (casual.expired != true))
  		@value = "affected"
  	end
  	if ((casual.team_id.eql?(nil)) && (casual.retired_from_ticking != true) && (casual.expired != true))
  		@value = "unaffected"
  	end
  	if ((casual.team_id != nil) && (casual.retired_from_ticking.eql?(true)) && (casual.expired != true))
  		@value = "retired"
  	end
  	if casual.expired.eql?(true)
  		@value = "expired"
  	end
  	@value
  end
  
  def casual_team(casual)
  	@team = Team.find_by_id(casual.team_id).team_name
  end
  
end

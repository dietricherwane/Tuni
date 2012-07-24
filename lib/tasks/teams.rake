namespace :teams do

	desc "Allot daily casuals to their default section"
	task :allot_daily_casuals_to_their_default_section => :environment do
		@daily_teams = Team.where("daily IS TRUE")
		unless @daily_teams.empty?
			@daily_teams.each do |team|
				@casuals = team.casuals
				unless @casuals.empty?
					@casuals.each do |casual|
						casual.update_attribute(:section_id, team.default_section)
					end
				end
			end
		end
	end
	
end

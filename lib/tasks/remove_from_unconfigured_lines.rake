namespace :on_sunday do

	desc "Remove casuals from lines their team aren't allowed to work on every sunday at 11.52pm"
	task :remove_casuals_from_forbidden_lines => :environment do
		@week = Date.today.cweek
		@next_week = Date.today.cweek + 1
		@teams_rolling_next_week = []
		@teams_to_be_checked = []
		@teams_rolling_current_week_and_not_next_week = []
# récupération des équipes tournant la semaine prochaine
		unless Configuration.where("week_number = #{@next_week}").empty?
			Configuration.where("week_number = #{@next_week}").each do |configuration|
				@teams_rolling_next_week << configuration.team
			end
		end
		
		Team.all.each do |team|
# On détermine les équipes qui tournent cette semaine		
			@configuration = team.configurations.where("week_number = #{@week}")
			if @configuration.empty?
# si cette équipe ne tourne pas cette semaine			
				@casuals = team.casuals
				unless @casuals.empty?
					@casuals.each do |casual|
# on supprime tous les temporaires de cette équipe des lignes						
						casual.update_attribute(:line_id, nil)
					end
				end
			else
# si cette équipe tourne cette semaine
				@configuration_nw = team.configurations.where("week_number = #{@next_week}")
# Si cette équipe ne tourne pas la semaine prochaine				
				if @configuration_nw.empty?
					@casuals = team.casuals
					unless @casuals.empty?
						@casuals.each do |casual|
# on supprime tous les temporaires de cette équipe des lignes						
							casual.update_attribute(:line_id, nil)
						end
					end
				end
			end
		end
				
# récupération des équipes tournant la semaine prochaine et la semaine en cours
		unless @teams_rolling_next_week.empty?
			@teams_rolling_next_week.each do |team|
				unless team.configurations.find_by_week_number(@week).nil?
					@teams_to_be_checked << team
				end
			end
		end
		
		unless @teams_to_be_checked.empty?
			@teams_to_be_checked.each do |team|
				@current_week_lines = team.configurations.find_by_week_number(@week).lines
				@next_week_lines = team.configurations.find_by_week_number(@next_week).lines
				@current_week_lines.each do |line|
	# Si une des lignes de la semaine en cours n'est pas incluse dans la liste des lignes de la semaine prochaine
					unless @next_week_lines.include?(line)
	# On sélectionne les temporaires travaillant sur cette ligne				
						@casuals = team.casuals.where("line_id = #{line.id}")
						unless @casuals.empty?
							@casuals.each do |casual|
	# on les supprime de cette ligne						
								casual.update_attribute(:line_id, nil)
							end
						end
					end
				end
			end
		end
	end	
end

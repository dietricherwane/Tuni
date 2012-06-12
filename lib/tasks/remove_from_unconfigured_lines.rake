namespace :on_sunday do

	desc "Remove casuals from lines their team aren't allowed to work on every sunday at 11.52pm"
	task :remove_unconfigured_casuals_from_lines => :environment do
		@week = Date.today.cweek
		@next_week = Date.today.cweek + 1
		@teams_rolling_next_week = []
		@teams_to_be_checked = []
# récupération des équipes tournant la semaine prochaine
		Configuration.where("week_number = #{@next_week}").each do |configuration|
			@teams_rolling_next_week << configuration.team
		end
# récupération des équipes tournant la semaine prochaine et la semaine en cours
		@teams_rolling_next_week.each do |team|
			unless team.configurations.find_by_week_number(@week).nil?
				@teams_to_be_checked << team
			end
		end
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

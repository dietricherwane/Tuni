namespace :on_sunday do

	desc "Ticking unticked casual every sunday at 11.45pm"
	task :tick_unticked_casuals => :environment do
		@week = Date.today.cweek
		@teams_configured_this_week = []
# récupération des équipes tournant cette semaine
		Configuration.where("week_number = #{@week}").each do |configuration|
			unless configuration.rolling_sunday.nil?
				@teams_configured_this_week << configuration.team
			end
		end

		unless @teams_configured_this_week.empty?
			@teams_configured_this_week.each do |team|
				team.casuals.each do |casual|
# Si des temporaires de cette équipe n'ont pas de pointage, on leur en crée un				
					unless casual.tickings.find_by_week_number(@week).nil?
						casual.tickings.create(:week_number => @week)
					end
					@ticking = casual.tickings.find_by_week_number(@week)
# S'ils n'ont pas de pointage du dimanche, on leur en crée un
					if @ticking.sunday_ticking.nil?
						@ticking.create_sunday_ticking(:time_description => team.configurations.find_by_week_number(@week).rolling_sunday.time_description, :number_of_hours => 0, :team_id => casual.team_id, :line_id => casual.line_id)
					end
				end
			end
		end 
	end
	
end

namespace :on_sunday do

	desc "Ticking unticked casual every sunday at 11.45pm"
	task :tick_unticked_casuals => :environment do
		@week = Date.today.cweek
		@teams_configured_this_week = []
# récupération des équipes tournant cette semaine
		Configuration.where("week_number = #{@week}").each do |configuration|
			@teams_configured_this_week << configuration.team
		end
		@teams_configured_this_week.each do |team|
			team.casuals.each do |casual|
				unless casual.tickings.find_by_week_number(@week).nil?
					casual.tickings.create(:week_number => @week)
				end
				@ticking = casual.tickings.find_by_week_number(@week)
				if @ticking.sunday_ticking.nil?
					@ticking.create_sunday_ticking(:time_description => team.configurations.find_by_week_number(@week).rolling_sunday.time_description, :number_of_hours => 0, :team_id => casual.team_id, :line_id => casual.line_id)
				end
			end
		end 
	end
	
end

# -*- encoding : utf-8 -*-
class TeamsController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_used
	
  def allot_to_line
  	@team = Team.find_by_id(current_user.status_number)
  	@configuration = Configuration.where("week_number = #{Date.today.cweek} AND team_id = #{@team.id}")
  	@casuals_without_lines = Casual.where("team_id = #{@team.id} AND line_id IS NULL AND expired IS NOT TRUE").paginate(:page => params[:casuals_without_lines], :per_page => 15)
  	@casuals = Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE").order("casual_type_id DESC, firstname ASC, lastname ASC").paginate(:page => params[:casuals], :per_page => 10)
  	@sections_array = []
  	@line_ids = ""
  	unless @configuration.first.nil?
  		@configuration.first.lines.each do |line|
  			unless @sections_array.include?(line.section.section_name)
  				@sections_array << line.section.section_name
  			end
  			@line_ids << line.id.to_i.to_s << ',' 			
  		end
  		@line_ids.sub!(/\,$/, '')
  	end
  	
  	@sections = @team.workshop.sections
  end
  
  def casual_allocation_to_line 
  	@line_name = params[:post][:line]
  	@casuals_hash = {}
# Delete line name from hash	
		@casuals_hash.merge!(params[:post]).except("line")
		@casual_checked = false
		@message = ""
		@casuals_hash.each_pair {|key, value|
	 		if value.to_i.eql?(1)
	 			@casual_checked =	true 			
	 		end
	  }
  	if (@line_name.nil? || @casual_checked.eql?(false))
  		redirect_to :back, :alert => "Veuillez choisir une ligne sur laquelle affecter les temporaires et cocher les temporaires à affecter."
  	else
  		@week_number = Date.today.cweek
  		@line = Line.find_by_line_name(@line_name)
  		@global_counter = 0
  		
  		@casuals_hash.each_pair {|key, value|
		 		if value.to_i.eql?(1)		 		
		 			@newcomer = Casual.find(key.to_i)
		 			@casual_type = @newcomer.casual_type
		 			@newcomer_configuration = @newcomer.team.configurations.where("week_number = #{@week_number}").first		 				 			
		 			
		 			@newcomer_monday_time = ""
		 			@newcomer_tuesday_time = ""
		 			@newcomer_wednesday_time = ""
		 			@newcomer_thursday_time = ""
		 			@newcomer_friday_time = ""
		 			@newcomer_saturday_time = ""
		 			@newcomer_sunday_time = ""
		 			
		 			@counter_monday = 0
		 			@counter_tuesday = 0
		 			@counter_wednesday = 0
		 			@counter_thursday = 0
		 			@counter_friday = 0
		 			@counter_saturday = 0
		 			@counter_sunday = 0
		 			
		 			newcomer_time(@newcomer_configuration, @newcomer_monday_time, "rolling_monday")		 			
		 			newcomer_time(@newcomer_configuration, @newcomer_tuesday_time, "rolling_tuesday")
		 			newcomer_time(@newcomer_configuration, @newcomer_wednesday_time, "rolling_wednesday")
		 			newcomer_time(@newcomer_configuration, @newcomer_thursday_time, "rolling_thursday")
		 			newcomer_time(@newcomer_configuration, @newcomer_friday_time, "rolling_friday")
		 			newcomer_time(@newcomer_configuration, @newcomer_saturday_time, "rolling_saturday")
		 			newcomer_time(@newcomer_configuration, @newcomer_sunday_time, "rolling_sunday")
		 					 				 			
		 			@teams_table = []		
		 			
# non expired casuals on selected line 			
		 			@casuals = Casual.where("line_id = #{@line.id} AND expired IS NOT TRUE AND casual_type_id = #{@casual_type.id}")

# tableau contenant la liste des équipes dont des temporaires tournent sur la ligne sélectionnée		 			
		 			@casuals.each do |casual|
		 				unless @teams_table.include?(casual.team)
		 					@teams_table << casual.team
		 				end		 				
		 			end

# s'il y a des temporaires sur la ligne...		 			
		 			unless @teams_table.empty?
			 			@teams_table.each do |team|
		 					@configuration = team.configurations.find_by_week_number(@week_number)
		 					unless @configuration.nil?
		 						
		 						day_counter(@configuration, team, @newcomer_monday_time, rolling_monday, @counter_monday)	
		 						day_counter(@configuration, team, @newcomer_tuesday_time, rolling_tuesday, @counter_tuesday)
		 						day_counter(@configuration, team, @newcomer_wednesday_time, rolling_wednesday, @counter_wednesday)
		 						day_counter(@configuration, team, @newcomer_thursday_time, rolling_thursday, @counter_thursday)
		 						day_counter(@configuration, team, @newcomer_friday_time, rolling_friday, @counter_friday)
		 						day_counter(@configuration, team, @newcomer_saturday_time, rolling_saturday, @counter_saturday)
		 						day_counter(@configuration, team, @newcomer_sunday_time, rolling_sunday, @counter_sunday)
		 						
		 					end
		 				end		 				
		 			end	 	
		 			
		 			if (@counter_monday.eql?(@line.max_number_of_casuals) || @counter_tuesday.eql?(@line.max_number_of_casuals) || @counter_wednesday.eql?(@line.max_number_of_casuals) || @counter_thursday.eql?(@line.max_number_of_casuals) || @counter_friday.eql?(@line.max_number_of_casuals) || @counter_saturday.eql?(@line.max_number_of_casuals) || @counter_sunday.eql?(@line.max_number_of_casuals))
						@message = "Tous les temporaires n'ont pas été affectés sur la ligne car le nombre maximal est atteint."
					else
						@newcomer.update_attribute(:line_id, @line.id)	
						@message = "Les temporaires ont été affectés sur la ligne: #{@line_name}." 						
					end								 			
		 		end		 		
			}						
			redirect_to :back, :notice => @message
  	end		  	
  end
  
  def newcomer_time(newcomer_configuration, newcomer_time, rolling_day)
  	@rolling_day_configuration = newcomer_configuration.send(rolling_day)
  	unless @rolling_day_configuration.nil?
			newcomer_time = @rolling_day_configuration.time_description
		end
  end
  
  def day_counter(configuration, team, newcomer_time, rolling_day, counter_day)
  	@rolling_day_configuration = configuration.send(rolling_day)
  	unless @rolling_day_configuration.nil?
			if @rolling_day_configuration.time_description.eql?(@newcomer_time)
				counter_day += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			end
		end
  end
  
  def remove_from_line
  	@casual = Casual.find(params[:format].to_i)
  	@line_name = Line.find(@casual.line_id).line_name
  	@casual.update_attribute(:line_id, nil)
  	redirect_to :back, :notice => "#{@casual.firstname} #{@casual.lastname} a été retiré de la ligne #{@line_name}."
  end
  
  def remove_from_team
  	@casual = Casual.find(params[:format].to_i)
  	@casual.update_attributes(:team_id => nil, :line_id => nil, :section_id => nil, :previous_team => current_user.status_number, :removal_week => Date.today.cweek)
  	redirect_to :back, :notice => "#{@casual.firstname} #{@casual.lastname} a été retiré de l'équipe."
  end
  
  def ticking
  	@team = Team.find(current_user.status_number)
  	@configuration = ""
  	@previous_configuration = ""
  	@sunday_config_exists = false 
  	@casuals = Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE AND (line_id IS NOT NULL OR casual_type_id = #{CasualType.find_by_type_name("Cariste").id})").order("casual_type_id DESC")
  	@weekday = Date.today.wday
  	@week_number = Date.today.cweek
  	@previous_week = Date.today.cweek - 1  	
  	@casuals_ticked_previous_sunday = []
  	
  	@sections_array = []
  	@line_ids = ""
  	unless @configuration.first.nil?
  		@configuration.first.lines.each do |line|
  			unless @sections_array.include?(line.section.section_name)
  				@sections_array << line.section.section_name
  			end
  			@line_ids << line.id.to_i.to_s << ',' 			
  		end
  		@line_ids.sub!(/\,$/, '')
  	end
  	
  	@sections = @team.workshop.sections
  	 	
  	unless @team.configurations.find_by_week_number(@week_number - 1).nil?
  		unless @team.configurations.find_by_week_number(@week_number - 1).rolling_sunday.nil?
  			@sunday_config_exists = true
  			@previous_configuration = @team.configurations.find_by_week_number(@previous_week)  			
  		end
  	end
 	 	
  	unless @team.configurations.where("week_number = #{@week_number}").empty?
  		@configuration = @team.configurations.where("week_number = #{@week_number}")
  	end
  	
  	@sections_array = []
  	@line_ids = ""
  	unless @configuration.empty?
  		@configuration.first.lines.each do |line|
  			unless @sections_array.include?(line.section.section_name)
  				@sections_array << line.section.section_name
  			end
  			@line_ids << line.id.to_i.to_s << ',' 			
  		end
  		@line_ids.sub!(/\,$/, '')
  	end
  	
  	@sections = @team.workshop.sections
  	 	
  end
  
  def save_ticking
  	@casuals_id_table = []
  	@raw_hash = {}
# nettoyage du hash
		@raw_hash.merge!(params).except!("utf8", "authenticity_token", "commit", "controller", "action")
# hash contenant la liste des correspondances: temporaire - pointages
# tableau contenant les id des temporaires pointés
		@raw_hash.each_pair {|key, value|
	 		if !is_not_a_number?(key)	
	 			@casuals_id_table << key
	 			@raw_hash.except!("#{key}")
	 		end
	  }
	  
	  if @raw_hash.empty?	  
	  	redirect_to :back, :alert => "Vous ne pouvez pas pointer."
	  else
	  	@week_number = Date.today.cweek	 
	  	@configuration = Casual.find_by_id(@casuals_id_table.first).team.configurations.find_by_week_number(@week_number) 
	  	@casuals_id_table.each do |casual_id|
	  		@casual = Casual.find(casual_id.to_i)
	  		# devrait aussi passer pour les caristes
	  		@line_id = @casual.line_id
	  		# pointage du dimanche précédent
	  		@last_sunday_ticking = @casual.tickings.find_by_week_number(Date.today.cweek - 1)
	  		unless params[("#{casual_id + "_last_sunday"}").to_sym].nil?
	  			if @last_sunday_ticking.sunday_ticking.nil?
	  				@last_sunday_ticking.create_sunday_ticking(:number_of_hours => params[(casual_id + "_last_sunday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id, :time_description => Casual.find(@casuals_id_table.first).team.configurations.find_by_week_number(@week_number - 1).rolling_sunday.time_description)
	  			else
						@last_sunday_ticking.sunday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_last_sunday").to_sym].to_i)
					end
				end
				
				@ticking = @casual.tickings.find_by_week_number(@week_number)
	  		# si le temporaire n'a pas encore été pointé...	  		
	  		if @ticking.nil?
					@casual.tickings.create(:week_number => @week_number)
					@ticking = @casual.tickings.find_by_week_number(@week_number)
					
					tick_unticked("monday", @casual, casual_id, @ticking, @configuration, @line_id)
					tick_unticked("tuesday", @casual, casual_id, @ticking, @configuration, @line_id)
					tick_unticked("wednesday", @casual, casual_id, @ticking, @configuration, @line_id)
					tick_unticked("thursday", @casual, casual_id, @ticking, @configuration, @line_id)
					tick_unticked("friday", @casual, casual_id, @ticking, @configuration, @line_id)
					tick_unticked("saturday", @casual, casual_id, @ticking, @configuration, @line_id)					
					tick_unticked("sunday", @casual, casual_id, @ticking, @configuration, @line_id)
					
				# si il a déjà été pointé...
				else			
				
					retick("monday", @casual, casual_id, @ticking, @configuration, @line_id)
					retick("tuesday", @casual, casual_id, @ticking, @configuration, @line_id)
					retick("wednesday", @casual, casual_id, @ticking, @configuration, @line_id)
					retick("thursday", @casual, casual_id, @ticking, @configuration, @line_id)
					retick("friday", @casual, casual_id, @ticking, @configuration, @line_id)
					retick("saturday", @casual, casual_id, @ticking, @configuration, @line_id)
					retick("sunday", @casual, casual_id, @ticking, @configuration, @line_id)
					
				end		
	  	end	
			redirect_to :back, :notice => "Le pointage a été fait."
		end
  end
  
##################################### BELONGS TO SAVE TICKING ################################  
  def tick_unticked(_day, casual, casual_id, ticking, configuration, line_id)
  	line_id.nil? ? @section_id = casual.team.workshop.sections.first.id : @section_id = Line.find_by_id(line_id).section.id
  		
  	unless params[("#{casual_id + "_" + _day}").to_sym].nil?
			ticking.send(("create_#{_day}_ticking").to_sym, :time_description => configuration.send("rolling_"+_day).time_description, :number_of_hours => params[("#{casual_id + "_" + _day}").to_sym].to_i, :line_id => line_id, :section_id => @section_id, :team_id => casual.team.id)
		end
  end
  
  def retick(_day, casual, casual_id, ticking, configuration, line_id)
  	line_id.nil? ? @section_id = casual.team.workshop.sections.first.id : @section_id = Line.find_by_id(line_id).section.id
  	
  	unless params[("#{casual_id}_#{_day}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
			if ticking.send(_day+"_ticking").nil?
				ticking.send(("create_#{_day}_ticking").to_sym, :time_description => configuration.send("rolling_"+_day).time_description, :number_of_hours => params[("#{casual_id + "_" + _day}").to_sym].to_i, :line_id => line_id, :section_id => @section_id, :team_id => casual.team.id)
			else
				ticking.send(_day+"_ticking").update_attributes(:number_of_hours => params[("#{casual_id + "_" + _day}").to_sym].to_i, :line_id => line_id, :section_id => @section_id)
			end
		end
  end
##################################### BELONGS TO SAVE TICKING ################################

  
  def rapport  	
  	@team = Team.find(current_user.status_number)
		@configuration = ""
  	@casuals = Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE")
  	#@casuals = Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE AND (line_id IS NOT NULL OR casual_type_id = #{CasualType.find_by_type_name("Cariste").id})")
  	
  	@normals = @casuals.where("casual_type_id = #{CasualType.find_by_type_name("Normal").id}")
  	@operators = @casuals.where("casual_type_id = #{CasualType.find_by_type_name("Cariste").id}")
  	
  	@weekday = Date.today.wday
  	@week_number = Date.today.cweek
  	unless @team.configurations.where("week_number = #{@week_number}").empty?
  		@configuration = @team.configurations.where("week_number = #{@week_number}")
  	end
  	
		respond_to do |format|
      format.html { render(:html => "rapport", :layout => false) }
      format.pdf { render(:pdf => "rapport", :footer => { :right => '[page] / [topage]' }, :layout => false) }
    end
  end
  
end

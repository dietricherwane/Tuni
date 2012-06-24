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
		 				 			
		 			@monday_time = ""
		 			@tuesday_time = ""
		 			@wednesday_time = ""
		 			@thursday_time = ""
		 			@friday_time = ""
		 			@saturday_time = ""
		 			@sunday_time = ""
		 			
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
		 			
		 			unless @newcomer_configuration.rolling_monday.nil?
		 				@newcomer_monday_time = @newcomer_configuration.rolling_monday.time_description
		 			end
		 			unless @newcomer_configuration.rolling_tuesday.nil?
		 				@newcomer_tuesday_time = @newcomer_configuration.rolling_tuesday.time_description
		 			end 
		 			unless @newcomer_configuration.rolling_wednesday.nil?
		 				@newcomer_wednesday_time = @newcomer_configuration.rolling_wednesday.time_description
		 			end 
		 			unless @newcomer_configuration.rolling_thursday.nil?
		 				@newcomer_thursday_time = @newcomer_configuration.rolling_thursday.time_description
		 			end 
		 			unless @newcomer_configuration.rolling_friday.nil?
		 				@newcomer_friday_time = @newcomer_configuration.rolling_friday.time_description
		 			end 
		 			unless @newcomer_configuration.rolling_saturday.nil?
		 				@newcomer_saturday_time = @newcomer_configuration.rolling_saturday.time_description
		 			end 
		 			unless @newcomer_configuration.rolling_sunday.nil?
		 				@newcomer_sunday_time = @newcomer_configuration.rolling_sunday.time_description
		 			end  
		 				 			
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
		 						unless @configuration.rolling_monday.nil?
			 						if @configuration.rolling_monday.time_description.eql?(@newcomer_monday_time)
			 							@counter_monday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
			 					unless @configuration.rolling_tuesday.nil?
			 						if @configuration.rolling_tuesday.time_description.eql?(@newcomer_tuesday_time)
			 							@counter_tuesday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
			 					unless @configuration.rolling_wednesday.nil?
			 						if @configuration.rolling_wednesday.time_description.eql?(@newcomer_wednesday_time)
			 							@counter_wednesday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
			 					unless @configuration.rolling_thursday.nil?
			 						if @configuration.rolling_thursday.time_description.eql?(@newcomer_thursday_time)
			 							@counter_thursday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
			 					unless @configuration.rolling_friday.nil?
			 						if @configuration.rolling_friday.time_description.eql?(@newcomer_friday_time)
			 							@counter_friday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
			 					unless @configuration.rolling_saturday.nil?
			 						if @configuration.rolling_saturday.time_description.eql?(@newcomer_saturday_time)
			 							@counter_saturday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
			 					unless @configuration.rolling_sunday.nil?
			 						if @configuration.rolling_sunday.time_description.eql?(@newcomer_sunday_time)
			 							@counter_sunday += team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
			 						end
			 					end
		 					end
		 					#@message << "#{team.team_name} || #{@counter_monday} #{@counter_tuesday} #{@counter_wednesday} #{@counter_thursday} #{@counter_friday} #{@counter_saturday} #{@counter_sunday} #{@newcomer_tuesday_time} || "
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
  
  def remove_from_line
  	@casual = Casual.find(params[:format].to_i)
  	@line_name = Line.find(@casual.line_id).line_name
  	@casual.update_attribute(:line_id, nil)
  	redirect_to :back, :notice => "#{@casual.firstname} #{@casual.lastname} a été retiré de la ligne #{@line_name}."
  end
  
  def remove_from_team
  	@casual = Casual.find(params[:format].to_i)
  	@casual.update_attributes(:team_id => nil, :previous_team => current_user.status_number, :removal_week => Date.today.cweek)
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
	  	@configuration = Casual.find(@casuals_id_table.first).team.configurations.find_by_week_number(@week_number) 
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
				
	  		# si le temporaire n'a pas encore été pointé...	  		
	  		if @casual.tickings.find_by_week_number(@week_number).nil?
					@casual.tickings.create(:week_number => @week_number)
					@ticking = @casual.tickings.find_by_week_number(@week_number)
					
					unless params[("#{casual_id + "_monday"}").to_sym].nil?
						@ticking.create_monday_ticking(:time_description => @configuration.rolling_monday.time_description, :number_of_hours => params[(casual_id + "_monday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
					unless params[("#{casual_id + "_tuesday"}").to_sym].nil?
						@ticking.create_tuesday_ticking(:time_description => @configuration.rolling_tuesday.time_description, :number_of_hours => params[(casual_id + "_tuesday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
					unless params[("#{casual_id + "_wednesday"}").to_sym].nil?
						@ticking.create_wednesday_ticking(:time_description => @configuration.rolling_wednesday.time_description, :number_of_hours => params[(casual_id + "_wednesday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
					unless params[("#{casual_id + "_thursday"}").to_sym].nil?
						@ticking.create_thursday_ticking(:time_description => @configuration.rolling_thursday.time_description, :number_of_hours => params[(casual_id + "_thursday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
					unless params[("#{casual_id + "_friday"}").to_sym].nil?
						@ticking.create_friday_ticking(:time_description => @configuration.rolling_friday.time_description, :number_of_hours => params[(casual_id + "_friday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
					unless params[("#{casual_id + "_saturday"}").to_sym].nil?
						@ticking.create_saturday_ticking(:time_description => @configuration.rolling_saturday.time_description, :number_of_hours => params[(casual_id + "_saturday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
					unless params[("#{casual_id + "_sunday"}").to_sym].nil?
						@ticking.create_sunday_ticking(:time_description => @configuration.rolling_sunday.time_description, :number_of_hours => params[(casual_id + "_sunday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
					end
				# si il a déjà été pointé...
				else	
					@ticking = @casual.tickings.find_by_week_number(@week_number)				
					unless params[("#{casual_id + "_monday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.monday_ticking.nil?
							@ticking.create_monday_ticking(:time_description => @configuration.rolling_monday.time_description, :number_of_hours => params[(casual_id + "_monday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.monday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_monday").to_sym].to_i)
						end
					end
					unless params[("#{casual_id + "_tuesday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.tuesday_ticking.nil?
							@ticking.create_tuesday_ticking(:time_description => @configuration.rolling_tuesday.time_description, :number_of_hours => params[(casual_id + "_tuesday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.tuesday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_tuesday").to_sym].to_i)
						end
					end
					unless params[("#{casual_id + "_wednesday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.wednesday_ticking.nil?
							@ticking.create_wednesday_ticking(:time_description => @configuration.rolling_wednesday.time_description, :number_of_hours => params[(casual_id + "_wednesday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.wednesday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_wednesday").to_sym].to_i)
						end
					end
					unless params[("#{casual_id + "_thursday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.thursday_ticking.nil?
							@ticking.create_thursday_ticking(:time_description => @configuration.rolling_thursday.time_description, :number_of_hours => params[(casual_id + "_thursday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.thursday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_thursday").to_sym].to_i)
						end
					end
					unless params[("#{casual_id + "_friday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.friday_ticking.nil?
							@ticking.create_friday_ticking(:time_description => @configuration.rolling_friday.time_description, :number_of_hours => params[(casual_id + "_friday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.friday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_friday").to_sym].to_i)
						end
					end
					unless params[("#{casual_id + "_saturday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.saturday_ticking.nil?
							@ticking.create_saturday_ticking(:time_description => @configuration.rolling_saturday.time_description, :number_of_hours => params[(casual_id + "_saturday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.saturday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_saturday").to_sym].to_i)
						end
					end
					unless params[("#{casual_id + "_sunday"}").to_sym].nil?
# Pour les temporaires ayant récemment changé d'équipe, ils peuvent avoir une config mais pas de pointage pour un jour de leur nouveau plan de production
						if @ticking.sunday_ticking.nil?
							@ticking.create_sunday_ticking(:time_description => @configuration.rolling_sunday.time_description, :number_of_hours => params[(casual_id + "_sunday").to_sym].to_i, :line_id => @line_id, :team_id => @casual.team.id)
						else
							@ticking.sunday_ticking.update_attributes(:number_of_hours => params[(casual_id + "_sunday").to_sym].to_i)
						end
					end
				end		
	  	end	
			redirect_to :back, :notice => "Le pointage a été fait."
		end
  end
  
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

# -*- encoding : utf-8 -*-
class TeamsController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_used
	
  def allot_to_line
  	@team = Team.find_by_id(current_user.status_number)
  	@configuration = Configuration.where("week_number = #{Date.today.cweek} AND team_id = #{@team.id}")
  	@casuals = Casual.where("team_id = #{@team.id}AND line_id IS NULL").paginate(:page => params[:page], :per_page => 15)
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
			@casuals_hash.merge!(params[:post])
			@casual_checked = false
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
		 			@newcomer = Casual.find_by_id(key.to_i)
		 			@casual_type = @newcomer.casual_type.type_name
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
		 			@casuals = Casual.where("line_id = #{@line.id} AND expired IS NOT TRUE AND casual_type_id = #{CasualType.find_by_type_name(@casual_type).id}")
		 			
		 			@casuals.each do |casual|
		 				unless @teams_table.include?(casual.team)
		 					@teams_table << casual.team
		 				end		 				
		 			end
		 			
		 			@teams_table.each do |team|
	 					@configuration = team.configurations.where("week_number = #{@week_number}").first
	 					unless @configuration.rolling_monday.nil?
	 						if @configuration.rolling_monday.time_description.eql?(@newcomer_monday_time)
	 							@counter_monday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 					unless @configuration.rolling_tuesday.nil?
	 						if @configuration.rolling_tuesday.time_description.eql?(@newcomer_monday_time)
	 							@counter_tuesday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 					unless @configuration.rolling_wednesday.nil?
	 						if @configuration.rolling_wednesday.time_description.eql?(@newcomer_monday_time)
	 							@counter_wednesday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 					unless @configuration.rolling_thursday.nil?
	 						if @configuration.rolling_thursday.time_description.eql?(@newcomer_monday_time)
	 							@counter_thursday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 					unless @configuration.rolling_friday.nil?
	 						if @configuration.rolling_friday.time_description.eql?(@newcomer_monday_time)
	 							@counter_friday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 					unless @configuration.rolling_saturday.nil?
	 						if @configuration.rolling_saturday.time_description.eql?(@newcomer_monday_time)
	 							@counter_saturday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 					unless @configuration.rolling_sunday.nil?
	 						if @configuration.rolling_sunday.time_description.eql?(@newcomer_monday_time)
	 							@counter_sunday += @configuration.team.casuals.where("line_id = #{@line.id} AND expired IS NOT TRUE").count
	 						end
	 					end
	 				end
	 				
	 				if @casual_type.eql?("Normal")
	 					if (@counter_monday.eql?(@line.max_number_of_casuals) || @counter_tuesday.eql?(@line.max_number_of_casuals) || @counter_wednesday.eql?(@line.max_number_of_casuals) || @counter_thursday.eql?(@line.max_number_of_casuals) || @counter_friday.eql?(@line.max_number_of_casuals) || @counter_saturday.eql?(@line.max_number_of_casuals) || @counter_sunday.eql?(@line.max_number_of_casuals))
	 						#redirect_to :back, :notice => "Le nombre maximal de temporaires de la ligne: #{@line_name} a été atteint. / #{@counter}"
	 						#break
	 						@message = "Tous les temporaires n'ont pas été affectés sur la ligne car le nombre maximal est atteint."
	 					else
	 						@newcomer.update_attribute(:line_id, @line.id)	
	 						@message = "Les temporaires ont été affectés sur la ligne: #{@line_name}." 						
	 					end 
	 				else
	 					if (@counter_monday.eql?(@line.max_number_of_casuals) || @counter_tuesday.eql?(@line.max_number_of_casuals) || @counter_wednesday.eql?(@line.max_number_of_casuals) || @counter_thursday.eql?(@line.max_number_of_casuals) || @counter_friday.eql?(@line.max_number_of_casuals) || @counter_saturday.eql?(@line.max_number_of_casuals) || @counter_sunday.eql?(@line.max_number_of_casuals))
	 						#redirect_to :back, :notice => "Le nombre maximal de caristes de la ligne: #{@line_name} a été atteint. / #{@counter}"
	 						#break
	 						@message = "Tous les temporaires n'ont pas été affectés sur la ligne car le nombre maximal est atteint."
	 					else
	 						@newcomer.update_attribute(:line_id, @line.id)
	 						@message = "Les temporaires ont été affectés sur la ligne: #{@line_name}."
	 						#break
	 					end
	 				end
		 			#@casual.update_attribute(:line_id, @line.id)		 			
		 		end
			}			
			redirect_to :back, :notice => @message
			#redirect_to :back, :notice => "Les temporaires ont été affectés sur la ligne: #{@line_name} / #{@counter_monday} #{@counter_tuesday} #{@counter_wednesday} #{@counter_thursday} #{@counter_friday} #{@counter_saturday} #{@counter_sunday} #{@newcomer_tuesday_time}."
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
  	@casual.update_attribute(:team_id, nil)
  	redirect_to :back, :notice => "#{@casual.firstname} #{@casual.lastname} a été retiré de l'équipe."
  end
  
  def ticking
  	@team = Team.find(current_user.status_number)
  	@configuration = ""
  	unless @team.configurations.where("week_number = #{Date.today.cweek}").empty?
  		@configuration = @team.configurations.where("week_number = #{Date.today.cweek}").first
  	end
  	@casuals = Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE AND line_id IS NOT NULL")
  	@weekday = Date.today.wday
  end

end

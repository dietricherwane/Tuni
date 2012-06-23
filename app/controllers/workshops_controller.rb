# -*- encoding : utf-8 -*-
class WorkshopsController < ApplicationController
	
	before_filter :authenticate_user!
	layout :layout_used
	
  def allot_to_team
  	@workshop = Workshop.find_by_id(current_user.status_number)
  	@teams = @workshop.teams.where("disabled IS NOT TRUE").order("team_name ASC")
  	@casuals = Casual.where("workshop_id = #{@workshop.id} AND team_id IS NULL AND expired IS NOT TRUE").paginate(:page => params[:page], :per_page => 15)
  end
  
  def casual_allocation
  	@team_id = params[:post][:team_id].to_i  
  	if params[:post][:team_id].empty?
  		redirect_to :back, :alert => "Veuillez choisir l'équipe dans laquelle affecter les temporaires."
  	else
			@casuals = {}
			@casuals.merge!(params[:post]).except(:post)
			@casual_checked = false
			@casuals.each_pair {|key, value|
		 		if value.to_i.eql?(1)
		 			@casual_checked =	true 			
		 		end
		  }
			if @casual_checked
				#if Casual.where("team_id = #{@team_id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE").count == Team.find(@team_id).max_number_of_casuals
					#redirect_to :back, :alert => "Le nombre maximal de temporaires dans cette équipe a déjà été atteint."
				#else
					@team = Team.find(@team_id)
			 		@casuals.each_pair {|key, value|
				 		if value.to_i.eql?(1)
				 			@casual = Casual.find(key.to_i)
				 			if CasualType.find(Casual.find(key.to_i).casual_type_id).type_name.eql?("Normal")
				 				if Casual.where("team_id = #{@team_id} AND casual_type_id = #{CasualType.find_by_type_name("Normal").id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE").count == @team.max_number_of_casuals
				 					@message = "Le nombre maximal de temporaires normaux de cette équipe a déjà été atteint."
				 				else
				 					@casual.update_attribute(:team_id, @team.id)
				 					@message = "Les temporaires ont été affectés dans l'équipe #{@team.team_name}."
				 				end
				 			else
				 				if Casual.where("team_id = #{@team_id} AND casual_type_id = #{CasualType.find_by_type_name("Cariste").id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE").count == @team.number_of_operators
				 					@message = "Le nombre maximal de caristes de cette équipe a déjà été atteint."
				 				else
				 					@casual.update_attribute(:team_id, @team.id)
				 					@message = "Les temporaires ont été affectés dans l'équipe #{@team.team_name}."
				 				end
				 			end
				 						 			
				 		end
					}		
					redirect_to :back, :notice => @message
				#end
			else
				redirect_to :back, :alert => "Veuillez affecter au moins un temporaire dans cette équipe."
			end
  	end
  end
  
  def parameters
  	@directions = Direction.all
  end
  
  def set_parameters
  	@team = Team.find_by_team_name(params[:team_name])
  	if @team.nil?
  		redirect_to :back, :alert => "Veuillez choisir l'équipe dont vous souhaitez modifier le nombre maximal de temporaires."
  	else
  		if (is_not_a_number?(params[:casual_number]) || params[:casual_number].to_i < 0 || is_not_a_number?(params[:operator_number]) || params[:operator_number].to_i < 0)
  			redirect_to :back, :alert => "Le nombre maximal de temporaires et de caristes doivent être des nombres supérieurs ou égaux à 0."
  		else
  			if params[:casual_number].to_i < Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE AND casual_type_id = #{CasualType.find_by_type_name('Normal').id}").count || params[:operator_number].to_i < Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE AND casual_type_id = #{CasualType.find_by_type_name('Cariste').id}").count
  				redirect_to :back, :alert => "Le nombre maximal d'ordinaires et de caristes doit etre supérieur au nombre de ceux présents dans l'équipe."
  			else
  				@team.update_attributes(:max_number_of_casuals => params[:casual_number].to_i, :number_of_operators => params[:operator_number].to_i)
  			redirect_to :back, :notice => "Le nombre maximal d'ordinaires et de caristes de l'équipe: #{@team.team_name} a été fixé à: #{params[:casual_number].to_i} et #{params[:operator_number].to_i}."
  			end
  		end
  	end
  end
  
  def line_parameters
  	@line = Line.find_by_line_name(params[:line_name])
  	if @line.nil?
  		redirect_to :back, :alert => "Veuillez choisir la ligne dont vous souhautez modifier le nombre maximal de temporaires."
  	else
  		if (is_not_a_number?(params[:no_casual_number]) || params[:no_casual_number].to_i <= 0)
  			redirect_to :back, :alert => "Le nombre maximal d'ordinaires doit être un nombre supérieur à 0."
  		else
  			if params[:no_casual_number].to_i < Casual.where("line_id = #{@line.id} AND casual_type_id = #{CasualType.find_by_type_name('Normal').id}").count
  				redirect_to :back, :alert => "Le nombre maximal d'ordinaires doit etre supérieur au nombre de ceux présents sur la ligne."
  			else
  				@line.update_attribute(:max_number_of_casuals, params[:no_casual_number].to_i)
  			redirect_to :back, :notice => "Le nombre maximal d'ordinaires de la ligne: #{@line.line_name} a été fixé à: #{params[:no_casual_number].to_i}."
  			end
  		end
  	end
  end
  
  def current_week_configuration_plan
  	configuration_plan(Date.today, Date.today.cweek)
  end
  
  def next_week_configuration_plan
  	configuration_plan((Date.today + 7), (Date.today.cweek + 1))
  end
  
  def configuration_plan(date, week_number)
  	@workshop = Workshop.find_by_id(current_user.status_number)
  	@teams = @workshop.teams.where("disabled IS NOT TRUE").order("team_name ASC")
  	@rolling_types = RollingType.where("description != 'Journalier'")
  	@beginning_of_next_week = (date).beginning_of_week
  	@end_of_next_week = (date).end_of_week
  	@configured_teams_table = []
  	@teams.each do |team|
  		unless Configuration.where("week_number = #{week_number} AND team_id = #{team.id}").empty?
  			@configured_teams_table << team
  		end
  	end
  end
  
  def save_current_week_configuration_plan
  	@team_id = params[:post][:team_id]  	
  	@lines = {}
		@lines.merge!(params[:post])
		@line_checked = false
		@line_id_table = []
		@lines.each_pair {|key, value|
	 		if value.to_i.eql?(1)
	 			@line_checked =	true
	 			@line_id_table << key.to_i 			 			
	 		end
		}  	
		
  	params[:monday_rolling_type].eql?(nil) ? @monday_plan = nil : @monday_plan = params[:monday_rolling_type]
  	params[:tuesday_rolling_type].eql?(nil) ? @tuesday_plan = nil : @tuesday_plan = params[:tuesday_rolling_type]
  	params[:wednesday_rolling_type].eql?(nil) ? @wednesday_plan = nil : @wednesday_plan = params[:wednesday_rolling_type]
  	params[:thursday_rolling_type].eql?(nil) ? @thursday_plan = nil : @thursday_plan = params[:thursday_rolling_type]
  	params[:friday_rolling_type].eql?(nil) ? @friday_plan = nil : @friday_plan = params[:friday_rolling_type]
  	params[:saturday_rolling_type].eql?(nil) ? @saturday_plan = nil : @saturday_plan = params[:saturday_rolling_type]
  	params[:sunday_rolling_type].eql?(nil) ? @sunday_plan = nil : @sunday_plan = params[:sunday_rolling_type]
 
  	@alert = <<-HTML
		  Veuillez choisir l'équipe dont vous souhaitez modifier la configuration ou le plan de production. 
		  <br />Cochez les lignes sur lesquelles doivent travailler cette équipe.
		  <br />Choisissez le nombre d'heures à effectuer par jour.
		HTML
  	 	
  	if (@team_id.empty? || (@line_checked.eql?(false) && !Team.find(@team_id).daily) || ((@monday_plan.nil? || @monday_plan.eql?("Horaire")) && (@tuesday_plan.nil? || @tuesday_plan.eql?("Horaire")) && (@wednesday_plan.nil? || @wednesday_plan.eql?("Horaire")) && (@thursday_plan.nil? || @thursday_plan.eql?("Horaire")) && (@friday_plan.nil? || @friday_plan.eql?("Horaire")) && (@saturday_plan.nil? || @saturday_plan.eql?("Horaire")) && (@sunday_plan.nil? || @sunday_plan.eql?("Horaire"))))
  		redirect_to :back, :alert => @alert.html_safe
  	else 		
  		@week_number = Date.today.cweek
  		@team = Team.find_by_id(@team_id.to_i)	
  		@configuration = Configuration.where(:week_number => @week_number, :team_id => @team.id).first	
  		
  		unless @line_checked.eql?(false)
				@line_id_table.each do |line_id|
					@configuration.lines << Line.find_by_id(line_id) if @configuration.lines.find_by_id(line_id).eql?(nil)
				end
			end
  		
  		unless (@monday_plan.nil? || @monday_plan.eql?("Horaire"))
  			RollingMonday.destroy(@configuration.rolling_monday.id) unless @configuration.rolling_monday.eql?(nil)
  			@configuration.create_rolling_monday(:time_description => RollingType.find_by_description(@monday_plan).description, :number_of_hours => RollingType.find_by_description(@monday_plan).number_of_hours)
  		end
  		unless (@tuesday_plan.nil? || @tuesday_plan.eql?("Horaire"))
  			RollingTuesday.destroy(@configuration.rolling_tuesday.id) unless @configuration.rolling_tuesday.eql?(nil)
  			@configuration.create_rolling_tuesday(:time_description => RollingType.find_by_description(@tuesday_plan).description, :number_of_hours => RollingType.find_by_description(@tuesday_plan).number_of_hours)
  		end
  		unless (@wednesday_plan.nil? || @wednesday_plan.eql?("Horaire"))
  			RollingWednesday.destroy(@configuration.rolling_wednesday.id) unless @configuration.rolling_wednesday.eql?(nil)
  			@configuration.create_rolling_wednesday(:time_description => RollingType.find_by_description(@wednesday_plan).description, :number_of_hours => RollingType.find_by_description(@wednesday_plan).number_of_hours)
  		end
  		unless (@thursday_plan.nil? || @thursday_plan.eql?("Horaire"))
  			RollingThursday.destroy(@configuration.rolling_thursday.id) unless @configuration.rolling_thursday.eql?(nil)
  			@configuration.create_rolling_thursday(:time_description => RollingType.find_by_description(@thursday_plan).description, :number_of_hours => RollingType.find_by_description(@thursday_plan).number_of_hours)
  		end
  		unless (@friday_plan.nil? || @friday_plan.eql?("Horaire"))
  			RollingFriday.destroy(@configuration.rolling_friday.id) unless @configuration.rolling_friday.eql?(nil)
  			@configuration.create_rolling_friday(:time_description => RollingType.find_by_description(@friday_plan).description, :number_of_hours => RollingType.find_by_description(@friday_plan).number_of_hours)
  		end
  		unless (@saturday_plan.nil? || @saturday_plan.eql?("Horaire"))
  			RollingSaturday.destroy(@configuration.rolling_saturday.id) unless @configuration.rolling_saturday.eql?(nil)
  			@configuration.create_rolling_saturday(:time_description => RollingType.find_by_description(@saturday_plan).description, :number_of_hours => RollingType.find_by_description(@saturday_plan).number_of_hours)
  		end
  		unless (@sunday_plan.nil? || @sunday_plan.eql?("Horaire"))
  			RollingSunday.destroy(@configuration.rolling_sunday.id) unless @configuration.rolling_sunday.eql?(nil)
  			@configuration.create_rolling_sunday(:time_description => RollingType.find_by_description(@sunday_plan).description, :number_of_hours => RollingType.find_by_description(@sunday_plan).number_of_hours)
  		end
  		 		
  		redirect_to :back, :notice => "#{Team.find_by_id(@team_id.to_i).team_name}: la configuration et le plan de production ont été faits."
  	end
  end
  
  def save_next_week_configuration_plan
  	@team_id = params[:post][:team_id]  	
  	@lines = {}
		@lines.merge!(params[:post])
		@line_checked = false
		@line_id_table = []
		@lines.each_pair {|key, value|
	 		if value.to_i.eql?(1)
	 			@line_checked =	true
	 			@line_id_table << key.to_i 			 			
	 		end
		}  	
  	@monday_plan = params[:monday_rolling_type]
  	@tuesday_plan = params[:tuesday_rolling_type]
  	@wednesday_plan = params[:wednesday_rolling_type]
  	@thursday_plan = params[:thursday_rolling_type]
  	@friday_plan = params[:friday_rolling_type]
  	@saturday_plan = params[:saturday_rolling_type]
  	@sunday_plan = params[:sunday_rolling_type]
  	@alert = <<-HTML
		  Veuillez choisir l'équipe dont vous souhaitez faire la configuration et le plan de production. 
		  <br />Cochez les lignes sur lesquelles doivent travailler cette équipe.
		  <br />Choisissez le nombre d'heures à effectuer par jour.
		HTML
  	@team = Team.find_by_id(@team_id.to_i) 	
# if no team has been checked || no line has been checked while the team is not daily; daily teams must not be checked || no hourly rate has been checked
  	if (@team_id.empty? || (@line_checked.eql?(false) && !@team.daily) || (@monday_plan.empty? && @tuesday_plan.empty? && @wednesday_plan.empty? && @thursday_plan.empty? && @friday_plan.empty? && @saturday_plan.empty? && @sunday_plan.empty?))
  		redirect_to :back, :alert => @alert.html_safe
  	else 		
  		@week_number = Date.today.cweek + 1
  		
  		@configuration_trash = Configuration.where(:week_number => @week_number, :team_id => @team.id).first
  		
  		method_delete_configuration_plan(@configuration_trash)

# configuration creation  		  		  		
  		@team.configurations.create(:user_id => current_user.id, :week_number => @week_number)  	
  		@configuration = Configuration.where(:week_number => @week_number, :team_id => @team.id).first	

# save lines the team can be affected to unless the team is daily 		
  		unless @team.daily
				@line_id_table.each do |line_id|
					@configuration.lines << Line.find_by_id(line_id)
				end
			end
  		
  		@configuration.create_rolling_monday(:time_description => RollingType.find_by_description(@monday_plan).description, :number_of_hours => RollingType.find_by_description(@monday_plan).number_of_hours) unless @monday_plan.eql?("Horaire")
  		@configuration.create_rolling_tuesday(:time_description => RollingType.find_by_description(@tuesday_plan).description, :number_of_hours => RollingType.find_by_description(@tuesday_plan).number_of_hours) unless @tuesday_plan.eql?("Horaire")
  		@configuration.create_rolling_wednesday(:time_description => RollingType.find_by_description(@wednesday_plan).description, :number_of_hours => RollingType.find_by_description(@wednesday_plan).number_of_hours) unless @wednesday_plan.eql?("Horaire")
  		@configuration.create_rolling_thursday(:time_description => RollingType.find_by_description(@thursday_plan).description, :number_of_hours => RollingType.find_by_description(@thursday_plan).number_of_hours) unless @thursday_plan.eql?("Horaire")
  		@configuration.create_rolling_friday(:time_description => RollingType.find_by_description(@friday_plan).description, :number_of_hours => RollingType.find_by_description(@friday_plan).number_of_hours) unless @friday_plan.eql?("Horaire")
  		@configuration.create_rolling_saturday(:time_description => RollingType.find_by_description(@saturday_plan).description, :number_of_hours => RollingType.find_by_description(@saturday_plan).number_of_hours) unless @saturday_plan.eql?("Horaire")
  		@configuration.create_rolling_sunday(:time_description => RollingType.find_by_description(@sunday_plan).description, :number_of_hours => RollingType.find_by_description(@sunday_plan).number_of_hours) unless @sunday_plan.eql?("Horaire")
  		redirect_to :back, :notice => "#{Team.find_by_id(@team_id.to_i).team_name}: la configuration équipe-lignes et le plan de production ont été faits."
  	end
  end
  
  def daily_team
  	@selected_team = params.first.first
  	Team.find_by_team_name(@selected_team).daily ? @daily = true : @daily = false
  	render :text => @daily
  end
  
  def delete_configuration_plan
  	method_delete_configuration_plan(Configuration.find_by_id(params[:format].to_i))
  	redirect_to :back
  end
  
  def method_delete_configuration_plan(configuration)
  	unless configuration.eql?(nil)
			configuration.lines.each do |line|
				configuration.lines.delete(line)
			end
			configuration.rolling_monday.delete unless configuration.rolling_monday.eql?(nil)
			configuration.rolling_tuesday.delete unless configuration.rolling_tuesday.eql?(nil)
			configuration.rolling_wednesday.delete unless configuration.rolling_wednesday.eql?(nil)
			configuration.rolling_thursday.delete unless configuration.rolling_thursday.eql?(nil)
			configuration.rolling_friday.delete unless configuration.rolling_friday.eql?(nil)
			configuration.rolling_saturday.delete unless configuration.rolling_saturday.eql?(nil)
			configuration.rolling_sunday.delete unless configuration.rolling_sunday.eql?(nil)
			configuration.delete
		end 	
  end
  
  def delete_line
  	@configuration = Configuration.find(params[:configuration].to_i)
  	@line = Line.find(params[:line].to_i)
  	@casuals_on_line = Casual.where("line_id = #{@line.id} AND team_id = #{@configuration.team.id}")
  	if @casuals_on_line.empty?
  		if casual_ticked_on_this_line?(@configuration.team_id, @line)
  			redirect_to :back, :alert => "Des temporaires ont été pointés sur la ligne #{@line.line_name}"
  		else
				if @configuration.lines.count < 2
					redirect_to :back, :alert => "#{@configuration.team.team_name}: il doit rester au moins une ligne dans la configuration."
				else
					@configuration.lines.delete(@line)
					redirect_to :back, :notice => "#{@configuration.team.team_name}: la ligne #{@line.line_name} a été supprimée de la configuration."
				end
			end
		else
			redirect_to :back, :alert => "Veuillez d'abord supprimer les temporaires affectés sur la ligne #{@line.line_name}"
		end
  end
  
  def casual_ticked_on_this_line?(team_id, line)
  	@ticked = false
  	@week_number = Date.today.cweek  	
		
# On récupère la liste de tous les temporaires car il peuvent changer d'atelier 			
		@casuals = Casual.all
# Si elle n'est pas vide, on la parcourt
		unless @casuals.empty?  			
			@casuals.each do |casual|
# Pour chacun des temporaires, on détermine s'il a un pointage
				@ticking = casual.tickings.find_by_week_number(@week_number)
# s'il a un pointage  					
				unless @ticking.nil?
# S'il a un pointage du lundi  					
					unless @ticking.monday_ticking.nil?
						if (@ticking.monday_ticking.line_id.eql?(line.id) && @ticking.monday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
					unless @ticking.tuesday_ticking.nil?
						if (@ticking.tuesday_ticking.line_id.eql?(line.id) && @ticking.tuesday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
					unless @ticking.wednesday_ticking.nil?
						if (@ticking.wednesday_ticking.line_id.eql?(line.id) && @ticking.wednesday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
					unless @ticking.thursday_ticking.nil?
						if (@ticking.thursday_ticking.line_id.eql?(line.id) && @ticking.thursday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
					unless @ticking.friday_ticking.nil?
						if (@ticking.friday_ticking.line_id.eql?(line.id) && @ticking.friday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
					unless @ticking.saturday_ticking.nil?
						if (@ticking.saturday_ticking.line_id.eql?(line.id) && @ticking.saturday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
					unless @ticking.sunday_ticking.nil?
						if (@ticking.sunday_ticking.line_id.eql?(line.id) && @ticking.sunday_ticking.team_id.eql?(team_id))
							@ticked = true
							break
						end
					end
				end
			end
		end
  	@ticked
  end
  
  def delete_working_day
  	@rolling_day = params[:model_name].constantize.find_by_id(params[:rolling_day_id].to_i)
  	@configuration = Configuration.find(params[:configuration].to_i)
  	if casual_ticked_this_day?(@configuration.team_id, params[:day_to_check].to_i)
  		redirect_to :back, :alert => "#{@configuration.team.team_name}: Des temporaires ont été pointés ce jour."
  	else
  		@rolling_day.delete
  		redirect_to :back, :notice => "#{@configuration.team.team_name}: le #{params[:french_date_name]} a été supprimé."
  	end
  	
  end
  
  def casual_ticked_this_day?(team_id, day_to_check)
  	@ticked = false
  	@week_number = Date.today.cweek  	

				@casuals = Casual.all
# S'il existe des temporaires dans ces équipes				
				unless @casuals.empty?
					@casuals.each do |casual|
						@ticking = casual.tickings.find_by_week_number(@week_number)
# Si le temporaire a un pointage						
						unless @ticking.nil?
# Si c'est le lundi qu'on veut supprimer de la configuration  et qu'il y a un pointage le lundi						
							if (day_to_check.eql?(1) && !@ticking.monday_ticking.nil?)
								if @ticking.monday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
							if (day_to_check.eql?(2) && !@ticking.tuesday_ticking.nil?)
								if @ticking.tuesday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
							if (day_to_check.eql?(3) && !@ticking.wednesday_ticking.nil?)
								if @ticking.wednesday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
							if (day_to_check.eql?(4) && !@ticking.thursday_ticking.nil?)
								if @ticking.thursday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
							if (day_to_check.eql?(5) && !@ticking.friday_ticking.nil?)
								if @ticking.friday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
							if (day_to_check.eql?(6) && !@ticking.saturday_ticking.nil?)
								if @ticking.saturday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
							if (day_to_check.eql?(0) && !@ticking.sunday_ticking.nil?)
								if @ticking.sunday_ticking.team_id.eql?(team_id)
									@ticked = true
								end
							end
						end
					end
				end
  	@ticked
  end
  
  def set_max_number_of_casuals_and_operators
  	
  end  
  
  def remove_from_workshop
  	@casual = Casual.find(params[:format].to_i)
  	@casual.update_attributes(:workshop_id => nil, :retired_from_ticking => true)
  	redirect_to :back, :notice => "#{@casual.firstname} #{@casual.lastname} a été retiré de l'atelier."
  end
  
  def get_correct_time_description
  	@selected_team = params.first.first
  	@time_description = "<option>Horaire</option>"
  	if Team.find_by_team_name(@selected_team).daily  		
			@time_description << "<option>#{RollingType.find_by_description("Journalier").description}</option>"			
  	else
			RollingType.where("description != 'Journalier'").each do |rolling_type|
				@time_description << "<option>#{rolling_type.description}</option>"
			end
  	end
  	render :text => @time_description
  end
  
  def chief_ticking
		@teams_table = []
		@week_number = Date.today.cweek		
		unless Workshop.find(current_user.status_number).teams.where("daily IS TRUE").empty?
			Workshop.find(current_user.status_number).teams.where("daily IS TRUE").each do |team|
				unless team.configurations.find_by_week_number(@week_number).nil?
					@teams_table << team
				end
			end
		end
  end
  
  def daily_team_ticking
  	@team = Team.find(params[:team_id])
  	@configuration = ""
  	@previous_configuration = ""
  	@sunday_config_exists = false 
  	@casuals = Casual.where("team_id = #{@team.id} AND expired IS NOT TRUE AND (line_id IS NULL OR casual_type_id = #{CasualType.find_by_type_name("Cariste").id})").order("casual_type_id DESC")
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
  
  def rapport
  	@team = Team.find_by_id(params[:team])
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
  
  def global_reports
  	@workshop = Workshop.find(current_user.status_number)
  	@sections = @workshop.sections
  end
  
  def section_global_report
  	@week_number = Date.new(params[:select][:"holiday(1i)"].to_i, params[:select][:"holiday(2i)"].to_i, params[:select][:"holiday(3i)"].to_i).cweek
  	#@week_number = Date.today.cweek
  	@lines_id_table = [] 	
  	@teams = []
  	@other_teams_table = []
  	@workshop_teams = Workshop.find_by_id(current_user.status_number).teams
  	
  	if (params[:normals][:validated].eql?("0") && params[:operators][:validated].eql?("0"))
  		@normals = true
  		@operators = true
  	else
			params[:normals][:validated].eql?("1") ? @normals = true : @normals = false
			params[:operators][:validated].eql?("1") ? @operators = true : @operators = false
		end
  	
# On récupère toutes les équipes de l'atelier
		if params[:post][:section_id].empty?
			@raw_teams = Workshop.find_by_id(current_user.status_number).teams.where("daily IS TRUE")
			@daily = true
		else
			@daily = false
			@section = Section.find_by_id(params[:post][:section_id])
  		@raw_teams = @section.workshop.teams.where("daily IS NOT TRUE")
  		
  		unless @section.lines.empty?
				@section.lines.each do |line|
					@lines_id_table << line.id
				end
			end
		end
		
		@other_teams_request = ""
		
  	unless @raw_teams.empty?  		  		
  		@raw_teams.each do |team|
# Sélection des équipes étant dans des ateliers différents de celui dans lequel on est
  			@other_teams_request << "team_name != '#{team.team_name}' AND "  		
# On stocke dans un tableau les équipes ayant une configuration pour la semaine en cours
  			unless team.configurations.find_by_week_number(@week_number).nil?
  				@teams << team
  			end
  		end  		
  		
  	end
  	
  	@other_teams_request.sub!(/ AND $/, "")
  	
  	if @other_teams_request.empty?
  			@other_teams = Team.all
  	else
  		@other_teams = Team.where("#{@other_teams_request}")
  	end
  	@tickings = []  	  	
  	unless @other_teams.empty?
  		@other_teams.each do |team|
  			team.casuals.each do |casual|
  				@ticking = casual.tickings.find_by_week_number(@week_number)
  				unless @ticking.nil?
  					@monday_ticking = @ticking.monday_ticking
  					@tuesday_ticking = @ticking.tuesday_ticking
  					@wednesday_ticking = @ticking.wednesday_ticking
  					@thursday_ticking = @ticking.thursday_ticking
  					@friday_ticking = @ticking.friday_ticking
  					@saturday_ticking = @ticking.saturday_ticking
  					@sunday_ticking = @ticking.sunday_ticking
  					
  					  					
  					unless @monday_ticking.nil?
  						if normal?(casual)
# Normal, on s'assure que la ligne dans laquelle il a été pointé appartient à la section sélectionnée ou que l'équipe dans laquelle il a été pointé appartient à l'atelier dans lequel on est si c'était un journalier			
								if @monday_ticking.line_id.nil?								 	
									if @raw_teams.include?(Team.find_by_id(@monday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@monday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end									
  						else
# Cariste, on s'assure que l'équipe dans laquelle il a été pointé appartient à l'atelier dans lequel on est
  							if @raw_teams.include?(Team.find_by_id(@monday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  					unless @tuesday_ticking.nil?
  						if normal?(casual)
  							if @tuesday_ticking.line_id.nil?
									if @raw_teams.include?(Team.find_by_id(@tuesday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@tuesday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end
  						else
  							if @raw_teams.include?(Team.find_by_id(@tuesday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  					unless @wednesday_ticking.nil?
  						if normal?(casual)
  							if @wednesday_ticking.line_id.nil?
									if @raw_teams.include?(Team.find_by_id(@wednesday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@wednesday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end
  						else
  							if @raw_teams.include?(Team.find_by_id(@wednesday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  					unless @thursday_ticking.nil?
  						if normal?(casual)
  							if @thursday_ticking.line_id.nil?
									if @raw_teams.include?(Team.find_by_id(@thursday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@thursday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end
  						else
  							if @raw_teams.include?(Team.find_by_id(@thursday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  					unless @friday_ticking.nil?
  						if normal?(casual)
  							if @friday_ticking.line_id.nil?
									if @raw_teams.include?(Team.find_by_id(@friday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@friday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end
  						else
  							if @raw_teams.include?(Team.find_by_id(@friday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  					unless @saturday_ticking.nil?
  						if normal?(casual)
  							if @saturday_ticking.line_id.nil?
									if @raw_teams.include?(Team.find_by_id(@saturday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@saturday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end
  						else
  							if @raw_teams.include?(Team.find_by_id(@saturday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  					unless @sunday_ticking.nil?
  						if normal?(casual)
  							if @sunday_ticking.line_id.nil?
									if @raw_teams.include?(Team.find_by_id(@sunday_ticking.team_id))
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								else
									if @lines_id_table.include?(@sunday_ticking.line_id)
										@other_teams_table << team unless @other_teams_table.include?(team)
									end
								end
  						else
  							if @raw_teams.include?(Team.find_by_id(@sunday_ticking.team_id))
  								@other_teams_table << team unless @other_teams_table.include?(team)
  							end
  						end
  					end
  					
  				end
  			end
  		end
  	end
  
  	respond_to do |format|
      format.html { render(:html => "section_global_report", :layout => false) }
      format.pdf { render(:pdf => "section_global_report", :footer => { :right => '[page] / [topage]' }, :layout => false) }
    end
  end
  
  def normals_global_report
  	if params[:post][:section_id].empty?
  		redirect_to :back, :alert => "Veuillez choisir une section."
  	else
  		@raw_casuals_table = []
  		@casuals = []
  		@week_number = Date.today.cweek
			@section = Section.find(params[:post][:section_id].to_i)
			@lines = @section.lines
			@teams = @section.workshop.teams.where("daily IS NOT TRUE")
			unless @teams.empty? && @lines.nil?
				@teams.each do |team|
					team.casuals.where("casual_type_id = #{CasualType.find_by_type_name("Normal").id}").each do |casual|
						@raw_casuals_table << casual
					end
				end
				@raw_casuals_table.each do |casual|
					unless casual.tickings.find_by_week_number(@week_number).nil?
						@ticking = casual.tickings.find_by_week_number(@week_number)
						unless @ticking.monday_ticking.nil?
							if @lines.include?(Line.find(@ticking.monday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
						unless @ticking.tuesday_ticking.nil?
							if @lines.include?(Line.find(@ticking.tuesday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
						unless @ticking.wednesday_ticking.nil?
							if @lines.include?(Line.find(@ticking.wednesday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
						unless @ticking.thursday_ticking.nil?
							if @lines.include?(Line.find(@ticking.thursday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
						unless @ticking.friday_ticking.nil?
							if @lines.include?(Line.find(@ticking.friday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
						unless @ticking.saturday_ticking.nil?
							if @lines.include?(Line.find(@ticking.saturday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
						unless @ticking.sunday_ticking.nil?
							if @lines.include?(Line.find(@ticking.sunday_ticking.line_id))
								unless @casuals.include?(casual)
									@casuals << casual
								end
							end
						end
					end
				end
			end
			
			  	
			respond_to do |format|
		    format.html { render(:html => "normals_global_report", :layout => false) }
		    format.pdf { render(:pdf => "normals_global_report", :footer => { :right => '[page] / [topage]' }, :layout => false) }
		  end
  	end
  end

end

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
			@casuals.merge!(params[:post])
			@casual_checked = false
			@casuals.each_pair {|key, value|
		 		if value.to_i.eql?(1)
		 			@casual_checked =	true 			
		 		end
		  }
			if @casual_checked
				if Casual.where("team_id = #{@team_id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE").count == Team.find_by_id(@team_id).max_number_of_casuals
					redirect_to :back, :alert => "Le nombre maximal de temporaires dans cette équipe a déjà été atteint."
				else
					@team = Team.find_by_id(@team_id)
			 		@casuals.each_pair {|key, value|
				 		if value.to_i.eql?(1)
				 			Casual.find_by_id(key.to_i).update_attribute(:team_id, Team.find_by_id(@team).id)		 			
				 		end
					}		
					redirect_to :back, :notice => "Les temporaires ont été affectés dans l'équipe #{@team.team_name}."
				end
			else
				redirect_to :back, :alert => "Veuillez affecter au moins un temporaire dans cette équipe."
			end
  	end
  end
  
  def parameters
  	@teams = Workshop.find_by_id(current_user.status_number).teams.order("team_name ASC")
  end
  
  def set_parameters
  	@team_id = params[:post][:team_id].to_i
  	if params[:post][:team_id].empty?
  		redirect_to :back, :alert => "Veuillez choisir l'équipe dont vous voulez modifier le nombre maximal de temporaires."
  	else
  		if is_not_a_number?(params[:casual_number]) || params[:casual_number].to_i <= 0
  			redirect_to :back, :alert => "Le nombre maximal de temporaires doit être un nombre supérieur à 0."
  		else
  			if params[:casual_number].to_i < Casual.where("team_id = #{@team_id} AND expired IS NOT TRUE AND retired_from_ticking IS NOT TRUE").count
  				redirect_to :back, :alert => "Le nombre maximal de temporaires est inférieur au nombre de temporaires dans l'équipe."
  			else
  				Team.find_by_id(params[:post][:team_id].to_i).update_attribute(:max_number_of_casuals, params[:casual_number].to_i)
  			redirect_to :back, :notice => "Le nombre maximal de temporaires de l'équipe: #{Team.find_by_id(params[:post][:team_id].to_i).team_name} a été fixé à: #{params[:casual_number].to_i}."
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
  	@rolling_types = RollingType.where("disabled IS NOT TRUE").order("type_name ASC")
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
		
  	params[:monday].eql?(nil) ? @monday_plan = '' : @monday_plan = params[:monday][:rolling_type_id]
  	params[:tuesday].eql?(nil) ? @tuesday_plan = '' : @tuesday_plan = params[:tuesday][:rolling_type_id]
  	params[:wednesday].eql?(nil) ? @wednesday_plan = '' : @wednesday_plan = params[:wednesday][:rolling_type_id]
  	params[:thursday].eql?(nil) ? @thursday_plan = '' : @thursday_plan = params[:thursday][:rolling_type_id]
  	params[:friday].eql?(nil) ? @friday_plan = '' : @friday_plan = params[:friday][:rolling_type_id]
  	params[:saturday].eql?(nil) ? @saturday_plan = '' : @saturday_plan = params[:saturday][:rolling_type_id]
  	params[:sunday].eql?(nil) ? @sunday_plan = '' : @sunday_plan = params[:sunday][:rolling_type_id]
 
  	@alert = <<-HTML
		  Veuillez choisir l'équipe dont vous souhaitez modifier la configuration ou le plan de production. 
		  <br />Cochez les lignes sur lesquelles doivent travailler cette équipe.
		  <br />Choisissez le nombre d'heures à effectuer par jour.
		HTML
  	 	
  	if (@team_id.empty? || (@line_checked.eql?(false) && (@monday_plan.empty? && @tuesday_plan.empty? && @wednesday_plan.empty? && @thursday_plan.empty? && @friday_plan.empty? && @saturday_plan.empty? && @sunday_plan.empty?)))
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
  		
  		unless @monday_plan.empty?
  			RollingMonday.destroy(@configuration.rolling_monday.id) unless @configuration.rolling_monday.eql?(nil)
  			@configuration.create_rolling_monday(:time_description => RollingType.find_by_id(@monday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@monday_plan.to_i).number_of_hours)
  		end
  		unless @tuesday_plan.empty?
  			RollingTuesday.destroy(@configuration.rolling_tuesday.id) unless @configuration.rolling_tuesday.eql?(nil)
  			@configuration.create_rolling_tuesday(:time_description => RollingType.find_by_id(@tuesday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@tuesday_plan.to_i).number_of_hours)
  		end
  		unless @wednesday_plan.empty?
  			RollingWednesday.destroy(@configuration.rolling_wednesday.id) unless @configuration.rolling_wednesday.eql?(nil)
  			@configuration.create_rolling_wednesday(:time_description => RollingType.find_by_id(@wednesday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@wednesday_plan.to_i).number_of_hours)
  		end
  		unless @thursday_plan.empty?
  			RollingThursday.destroy(@configuration.rolling_thursday.id) unless @configuration.rolling_thursday.eql?(nil)
  			@configuration.create_rolling_thursday(:time_description => RollingType.find_by_id(@thursday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@thursday_plan.to_i).number_of_hours)
  		end
  		unless @friday_plan.empty?
  			RollingFriday.destroy(@configuration.rolling_friday.id) unless @configuration.rolling_friday.eql?(nil)
  			@configuration.create_rolling_friday(:time_description => RollingType.find_by_id(@friday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@friday_plan.to_i).number_of_hours)
  		end
  		unless @saturday_plan.empty?
  			RollingSaturday.destroy(@configuration.rolling_saturday.id) unless @configuration.rolling_saturday.eql?(nil)
  			@configuration.create_rolling_saturday(:time_description => RollingType.find_by_id(@saturday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@saturday_plan.to_i).number_of_hours)
  		end
  		unless @sunday_plan.empty?
  			RollingSunday.destroy(@configuration.rolling_sunday.id) unless @configuration.rolling_sunday.eql?(nil)
  			@configuration.create_rolling_sunday(:time_description => RollingType.find_by_id(@sunday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@sunday_plan.to_i).number_of_hours)
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
  	@monday_plan = params[:monday][:rolling_type_id]
  	@tuesday_plan = params[:tuesday][:rolling_type_id]
  	@wednesday_plan = params[:wednesday][:rolling_type_id]
  	@thursday_plan = params[:thursday][:rolling_type_id]
  	@friday_plan = params[:friday][:rolling_type_id]
  	@saturday_plan = params[:saturday][:rolling_type_id]
  	@sunday_plan = params[:sunday][:rolling_type_id]
  	@alert = <<-HTML
		  Veuillez choisir l'équipe dont vous souhaitez faire la configuration et le plan de production. 
		  <br />Cochez les lignes sur lesquelles doivent travailler cette équipe.
		  <br />Choisissez le nombre d'heures à effectuer par jour.
		HTML
  	@team = Team.find_by_id(@team_id.to_i) 	
  	if (@team_id.empty? || (@line_checked.eql?(false) && !@team.daily) || (@monday_plan.empty? && @tuesday_plan.empty? && @wednesday_plan.empty? && @thursday_plan.empty? && @friday_plan.empty? && @saturday_plan.empty? && @sunday_plan.empty?))
  		redirect_to :back, :alert => @alert.html_safe
  	else 		
  		@week_number = Date.today.cweek + 1
  		
  		@configuration_trash = Configuration.where(:week_number => @week_number, :team_id => @team.id).first
  		
  		method_delete_configuration_plan(@configuration_trash)
  		  		  		
  		@team.configurations.create(:user_id => current_user.id, :week_number => @week_number)  	
  		@configuration = Configuration.where(:week_number => @week_number, :team_id => @team.id).first	
  		
  		unless @team.daily
				@line_id_table.each do |line_id|
					@configuration.lines << Line.find_by_id(line_id)
				end
			end
  		
  		@configuration.create_rolling_monday(:time_description => RollingType.find_by_id(@monday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@monday_plan.to_i).number_of_hours) unless @monday_plan.empty?
  		@configuration.create_rolling_tuesday(:time_description => RollingType.find_by_id(@tuesday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@tuesday_plan.to_i).number_of_hours) unless @tuesday_plan.empty?
  		@configuration.create_rolling_wednesday(:time_description => RollingType.find_by_id(@wednesday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@wednesday_plan.to_i).number_of_hours) unless @wednesday_plan.empty?
  		@configuration.create_rolling_thursday(:time_description => RollingType.find_by_id(@thursday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@thursday_plan.to_i).number_of_hours) unless @thursday_plan.empty?
  		@configuration.create_rolling_friday(:time_description => RollingType.find_by_id(@friday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@friday_plan.to_i).number_of_hours) unless @friday_plan.empty?
  		@configuration.create_rolling_saturday(:time_description => RollingType.find_by_id(@saturday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@saturday_plan.to_i).number_of_hours) unless @saturday_plan.empty?
  		@configuration.create_rolling_sunday(:time_description => RollingType.find_by_id(@sunday_plan.to_i).description, :number_of_hours => RollingType.find_by_id(@sunday_plan.to_i).number_of_hours) unless @sunday_plan.empty?
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
  	@configuration = Configuration.find_by_id(params[:configuration].to_i)
  	@line = Line.find_by_id(params[:line].to_i)
  	
  	if @configuration.lines.count < 2
  		redirect_to :back, :alert => "#{@configuration.team.team_name}: il doit rester au moins une ligne dans la configuration."
  	else
			@configuration.lines.delete(@line)
			redirect_to :back, :notice => "#{@configuration.team.team_name}: la ligne #{@line.line_name} a été supprimée de la configuration."
		end
  end
  
  def delete_working_day
  	@rolling_day = params[:model_name].constantize.find_by_id(params[:rolling_day_id].to_i)
  	@configuration = Configuration.find_by_id(params[:configuration].to_i)
  	@rolling_day.delete
  	redirect_to :back, :notice => "#{@configuration.team.team_name}: le #{params[:french_date_name]} a été supprimé."
  end
  
  

end

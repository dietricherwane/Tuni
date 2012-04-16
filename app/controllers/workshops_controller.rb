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
				redirect_to :back, :alert => "Veuillez affecter au moins un temporaire."
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
  			redirect_to :back, :alert => "Le nombre maximal de temporaires ne doit pas être vide et doit être numérique."
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
  
  def configuration_plan
  	@workshop = Workshop.find_by_id(current_user.status_number)
  	@teams = @workshop.teams.where("disabled IS NOT TRUE").order("team_name ASC")
  	@rolling_types = RollingType.where("disabled IS NOT TRUE").order("type_name ASC")
  end
  
  def save_configuration_plan
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
  
  	if (@team_id.empty? || @line_checked.eql?(false) || (@monday_plan.empty? && @tuesday_plan.empty? && @wednesday_plan.empty? && @thursday_plan.empty? && @friday_plan.empty? && @saturday_plan.empty? && @sunday_plan.empty?))
  		redirect_to :back, :alert => @alert.html_safe
  	else 		
  		@week_number = Date.today.cweek + 2
  		@team = Team.find_by_id(@team_id.to_i)
  		@team.configurations.create(:user_id => current_user.id, :week_number => @week_number)
  		@configuration = Configuration.where(:week_number => @week_number, :team_id => @team.id).last
  		@line_id_table.each do |line_id|
  			@configuration.lines << Line.find_by_id(line_id)
  		end
  		
  		@configuration.create_rolling_monday(:time_amount => RollingType.find_by_id(@monday_plan.to_i).number_of_hours) unless @monday_plan.empty?
  		@configuration.create_rolling_tuesday(:time_amount => RollingType.find_by_id(@tuesday_plan.to_i).number_of_hours) unless @tuesday_plan.empty?
  		@configuration.create_rolling_wednesday(:time_amount => RollingType.find_by_id(@wednesday_plan.to_i).number_of_hours) unless @wednesday_plan.empty?
  		@configuration.create_rolling_thursday(:time_amount => RollingType.find_by_id(@thursday_plan.to_i).number_of_hours) unless @thursday_plan.empty?
  		@configuration.create_rolling_friday(:time_amount => RollingType.find_by_id(@friday_plan.to_i).number_of_hours) unless @friday_plan.empty?
  		@configuration.create_rolling_saturday(:time_amount => RollingType.find_by_id(@saturday_plan.to_i).number_of_hours) unless @saturday_plan.empty?
  		@configuration.create_rolling_sunday(:time_amount => RollingType.find_by_id(@sunday_plan.to_i).number_of_hours) unless @sunday_plan.empty?
  		redirect_to :back, :notice => "#{Team.find_by_id(@team_id.to_i).team_name}: la configuration et le plan de production ont été faits."
  	end
  end

end

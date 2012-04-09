# -*- encoding : utf-8 -*-
class WorkshopsController < ApplicationController
	
	before_filter :authenticate_user!
	layout :layout_used
	
  def allot_to_team
  	@workshop = Workshop.find_by_id(current_user.status_number)
  	@teams = @workshop.teams.order("team_name ASC")
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

end

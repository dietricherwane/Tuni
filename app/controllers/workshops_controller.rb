# -*- encoding : utf-8 -*-
class WorkshopsController < ApplicationController
	
	before_filter :authenticate_user!
	layout :layout_used
	
  def allot_to_team
  	@workshop = Workshop.find_by_id(current_user.status_number)
  	@teams = @workshop.teams
  	@casuals = Casual.where("workshop_id = #{@workshop.id} AND team_id IS NULL AND expired IS NOT TRUE").paginate(:page => params[:page], :per_page => 10)
  	@casual = Casual.new
  end
  
  def casual_allocation
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
				@team = Team.find_by_id(params[:post][:team_id].to_i)
		 		@casuals.each_pair {|key, value|
			 		if value.to_i.eql?(1)
			 			Casual.find_by_id(key.to_i).update_attribute(:team_id, Team.find_by_id(@team).id)		 			
			 		end
				}		
				redirect_to :back, :notice => "Les temporaires ont été affectés dans l'équipe #{@team.team_name}."
			else
				redirect_to :back, :alert => "Veuillez affecter au moins un temporaire."
			end
  	end
  end

end

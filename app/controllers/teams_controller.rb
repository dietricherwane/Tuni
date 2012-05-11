# -*- encoding : utf-8 -*-
class TeamsController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_used
	
  def allot_to_line
  	@team = Team.find_by_id(current_user.status_number)
  	@casuals = Casual.where("team_id = #{@team.id}AND line_id IS NULL").paginate(:page => params[:page], :per_page => 15)
  	@sections = @team.workshop.sections
  end
  
  def casual_allocation_to_line 
  	@line_name = params[:post][:line]
  	@casuals = {}
			@casuals.merge!(params[:post])
			@casual_checked = false
			@casuals.each_pair {|key, value|
		 		if value.to_i.eql?(1)
		 			@casual_checked =	true 			
		 		end
		  }
  	if (@line_name.nil? || @casual_checked.eql?(false))
  		redirect_to :back, :alert => "Veuillez choisir une ligne sur laquelle affecter les temporaires et cocher les temporaires à affecter."
  	else
  		@line = Line.find_by_line_name(@line_name)
  		@casuals.each_pair {|key, value|
		 		if value.to_i.eql?(1)
		 			Casual.find_by_id(key.to_i).update_attribute(:line_id, @line.id)		 			
		 		end
			}
			redirect_to :back, :notice => "Les temporaires ont été affectés sur la ligne: #{@line_name}."
  	end
 		
  end

end

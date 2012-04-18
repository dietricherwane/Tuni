# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_cache_buster
  
  def change_password
  	if user_signed_in?
			if (current_user.sign_in_count.eql?(1) && current_user.reset_password_token.eql?(nil))
				redirect_to new_user_password_path
			end
			if (current_user.sign_in_count.eql?(1) && (current_user.reset_password_token != nil))
				redirect_to new_user_session_path, :notice => "Un email vient de vous être envoyé avec un lien pour changer votre mot de passe."
			end
		end
  end
  
  def translate_status(original_status, direction_name, workshop_name, team_name)
  	@status_number = 0
  	@status_name = Status.find_by_id(original_status).status_name
  	case @status_name
  	when "Chef de direction"
  		@status_number = Direction.find_by_direction_name(direction_name).id
  	when "Chef d'atelier"
  		@status_number = Workshop.find_by_workshop_name(workshop_name).id
  	when "Chef d'équipe"
  		@status_number = Team.find_by_team_name(team_name).id
  	end
  	@status_number
  end
  
  def logout_disabled_user
    if current_user.eql?(nil)
    	sign_out(current_user)
   	  redirect_to sign_in_path, :notice => "Veuillez d'abord vous connecter."
   	else
		  unless current_user.user_enabled?(current_user)
		 	  sign_out(current_user)
		 	  redirect_to sign_in_path, :notice => "Votre compte a été désactivé, veuillez contacter l'administrateur."
		  end
		end
  end 
  
  def layout_used
  	@user_status = current_user_status
  	case @user_status
			when 'Administrateur'
				"application"
			when 'Chef de direction'
				"direction_chief"
			when "Chef d'atelier"
				"workshop_chief"
			when "Chef d'équipe"
				"team_chief"
			else
				"default"
			end
  end 
  
  def current_user_status
  	@user_status = ""
    if current_user.eql?(nil)
    	#sign_out(current_user)
   	  #redirect_to sign_in_path, :notice => "Veuillez d'abord vous connecter."
   	else
		  @user_status = Status.find_by_id(current_user.status_id).status_name
		end
  end  
  
  def capitalization(raw_name)
  	@name_capitalized = ''
  	raw_name.split.each do |name|
  		@name_capitalized << "#{name.capitalize} "
  	end
  	@name_capitalized.strip
  end
  
  def is_not_a_number?(s)
  	s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? true : false 
	end
	
	def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
end

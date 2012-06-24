# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user!, :logout_disabled_user, :set_cache_buster, :layout_used
  helper_method :holiday?, :hours_worked
  #before_filter :set_cache_buster
  #before_filter :logout_disabled_user
  #before_filter :authenticate_user!
  
  def duke
  	unless user_signed_in?
  		redirect_to root_path, :alert => "Access Denied"
  	end
  end
  
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
    #if current_user.eql?(nil)
    	#sign_out(current_user)
   	  #redirect_to sign_in_path, :notice => "Veuillez d'abord vous connecter."
   	#else
   	if user_signed_in?
		  if current_user.user_enabled?(current_user).eql?(false)
		 	  sign_out(current_user)
		 	  redirect_to sign_in_path, :notice => "Votre compte a été désactivé, veuillez contacter l'administrateur."
		  end
		end
		#end
  end 
  
  def layout_used
  	@user_status = current_user_status 
  	if user_signed_in?
  		if ((current_user.sign_in_count == 1) && current_user.reset_password_token.nil?)
				"default"
			else	
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
		@user_status
  end  
  
  def capitalization(raw_string)
  	@string_capitalized = ''
  	raw_string.split.each do |name|
  		@string_capitalized << "#{name.capitalize} "
  	end
  	@string_capitalized.strip
  end
  
  def is_not_a_number?(n)
  	n.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? true : false 
	end
	
	def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end  
  
  def holiday?(week_number, week_day)
  	@status = false
  	@holidays = Holiday.where("week_number = #{week_number}")
  	if @holidays.empty?
  		@status = false
  	else
  		@holidays.each do |holiday|
  			if holiday.holiday.wday.eql?(week_day)
  				@status = true
  			end
  		end
  	end
  	@status
  end
  
  def hours_worked(casual, week_number, lines_id_table)
  	@counter = 0
  	@ticking = casual.tickings.find_by_week_number(week_number)
  	unless @ticking.nil?
  		unless @ticking.monday_ticking.nil?
  			if lines_id_table.include?(@ticking.monday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.monday_ticking.number_of_hours
  			end
  		end
  		unless @ticking.tuesday_ticking.nil?
  			if lines_id_table.include?(@ticking.tuesday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.tuesday_ticking.number_of_hours
  			end
  		end
  		unless @ticking.wednesday_ticking.nil?
  			if lines_id_table.include?(@ticking.wednesday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.wednesday_ticking.number_of_hours
  			end
  		end
  		unless @ticking.thursday_ticking.nil?
  			if lines_id_table.include?(@ticking.thursday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.thursday_ticking.number_of_hours
  			end
  		end
  		unless @ticking.friday_ticking.nil?
  			if lines_id_table.include?(@ticking.friday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.friday_ticking.number_of_hours
  			end
  		end
  		unless @ticking.saturday_ticking.nil?
  			if lines_id_table.include?(@ticking.saturday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.saturday_ticking.number_of_hours
  			end
  		end
  		unless @ticking.sunday_ticking.nil?
  			if lines_id_table.include?(@ticking.sunday_ticking.line_id) || Team.find_by_id(casual.team.id).daily
  				@counter += @ticking.sunday_ticking.number_of_hours
  			end
  		end
  	end
  	@counter
  end
  
end

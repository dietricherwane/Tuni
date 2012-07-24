# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user!, :logout_disabled_user, :set_cache_buster, :layout_used
  helper_method :holiday?, :hours_worked, :team_and_operators_hours_worked, :team_chief_ticking, :workshop_chief_ticking
  
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
  
  def hours_worked(casual, week_number, section_id)
  	@counter = 0
  	@ticking = casual.tickings.find_by_week_number(week_number)
  	unless @ticking.nil?
  	
  		@counter += hours_worked_counter_function(@ticking, "monday", section_id)
  		@counter += hours_worked_counter_function(@ticking, "tuesday", section_id)
  		@counter += hours_worked_counter_function(@ticking, "wednesday", section_id)
  		@counter += hours_worked_counter_function(@ticking, "thursday", section_id)
  		@counter += hours_worked_counter_function(@ticking, "friday", section_id)
  		@counter += hours_worked_counter_function(@ticking, "saturday", section_id)
  		@counter += hours_worked_counter_function(@ticking, "sunday", section_id)
  		
  	end
  	@counter
  end
  
  def hours_worked_counter_function(ticking, _day, section_id)
  	@ticking_day = ticking.send(_day+"_ticking")
  	@ct = 0
  	unless @ticking_day.nil?
			if @ticking_day.section_id.eql?(section_id)
				@ct += @ticking_day.number_of_hours
			end
		end
		@ct
  end
  
  def team_and_operators_hours_worked(casual, week_number)
  	@counter = 0
  	@ticking = casual.tickings.find_by_week_number(week_number)
  	unless @ticking.nil?
  		unless @ticking.monday_ticking.nil?
  			@counter += @ticking.monday_ticking.number_of_hours
  		end
  		unless @ticking.tuesday_ticking.nil?
  			@counter += @ticking.tuesday_ticking.number_of_hours
  		end
  		unless @ticking.wednesday_ticking.nil?
  			@counter += @ticking.wednesday_ticking.number_of_hours
  		end
  		unless @ticking.thursday_ticking.nil?
  			@counter += @ticking.thursday_ticking.number_of_hours
  		end
  		unless @ticking.friday_ticking.nil?
  			@counter += @ticking.friday_ticking.number_of_hours
  		end
  		unless @ticking.saturday_ticking.nil?
  			@counter += @ticking.saturday_ticking.number_of_hours
  		end
  		unless @ticking.sunday_ticking.nil?
  			@counter += @ticking.sunday_ticking.number_of_hours
  		end
  	end
  	@counter
  end
  
  def normal?(casual)
  	casual.casual_type_id.eql?(CasualType.find_by_type_name("Normal").id) ? @result = true : @result = false
  	@result
  end
  
  def team_chief_ticking(casual, week_number, configuration, weekday, day1, day2, _day)
  	@ticking_displayed = ""
  	 	
# Pour les pointages du jour et de la veille; si on est lundi ou mardi... -->
		if (weekday == day1 || weekday == day2)
			@ticking = casual.tickings.find_by_week_number(week_number)
# On est lundi ou mardi: Si le temporaire n'a pas encore été pointé cette semaine ou ce jour, on affiche le nombre d'heures de la configuration -->
			if (@ticking.nil? || @ticking.send(_day+"_ticking").nil?)
				@number_of_hours = configuration.first.send("rolling_"+_day).number_of_hours				
				@ticking_displayed = "select_tag '#{casual.id}_#{_day}', options_for_select((0..#{@number_of_hours}).map{|s| s}), :style => 'width:100%'"
			else
# Le temporaire a été pointé le lundi: Si l'équipe dans laquelle il a été pointé est différente de celle dans laquelle il est; se contenter d'afficher le nombre d'heures précédemment pointé --><div style='font-size:60%;'>
				@ticking_day = casual.tickings.where("week_number = #{configuration.first.week_number}").first.send(_day+"_ticking")
				if @ticking_day.team_id != casual.team_id
					@ticking_displayed = @ticking_day.number_of_hours.to_s															
				else
# Le temporaire a été pointé le lundi: Si l'équipe dans laquelle il a été pointé est la meme que celle dans laquelle il est; afficher une combo box de sélection des heures -->														
					@ticking_displayed = "select_tag '#{casual.id}_#{_day}', options_for_select((0..#{configuration.first.send("rolling_"+_day).number_of_hours}).to_a.map{|s| s}, #{casual.tickings.find_by_week_number(week_number).send(_day+"_ticking").number_of_hours}), :style => 'width:100%'"
				end
			end
		else
			@ticking = casual.tickings.where("week_number = #{configuration.first.week_number}")
			if @ticking.empty?
				@ticking_displayed = 0
			else
				if @ticking.first.send(_day+"_ticking").nil?
					@ticking_displayed = 0
				else
					@ticking_day = @ticking.first.send(_day+"_ticking")
					@ticking_displayed = @ticking_day.number_of_hours
				end
			end
		end
		@ticking_displayed.to_s
  end
  
  def workshop_chief_ticking(_day, week_number, casual, section_id, day_number)
  	@results_hash = {}
  	@pp = 0
  	@h75 = 0
  	@h100 = 0
  	
  	@ticking_displayed = ""
# Le temporaire a été pointé cette semaine: Si le temporaire n'a pas été pointé le lundi, on affiche le nombre d'heures de la configuration	
		@ticking_day = casual.tickings.find_by_week_number(week_number).send(_day+"_ticking")								
		if @ticking_day.nil?
			@ticking_displayed = 0
		else							
# Le temporaire a été pointé le lundi: Si l'équipe dans laquelle il a été pointé est différente de celle dans laquelle il est; se contenter d'afficher le nombre d'heures précédemment pointé
			@rolling_day = Team.find_by_id(@ticking_day.team_id).configurations.find_by_week_number(@week_number).send("rolling_"+_day)
			if @ticking_day.section_id.eql?(section_id)																		
				@ticking_displayed = @ticking_day.number_of_hours
				if @rolling_day.time_description.eql?("Nuit") 
					@pp = 1
				end	
# Si le jour est férié ...		
				if holiday?(week_number, day_number)
# 100% pour les journaliers et les temporaires travaillant de nuit				
					if casual.team.daily || @rolling_day.time_description.eql?("Nuit")
						@h100 = @ticking_day.number_of_hours
					else
# 75% pour les temporaires ne travaillant pas de nuit					
						@h75 = @ticking_day.number_of_hours
					end					
				else
# 75% pour les journaliers travaillant samedi et dimanche				
					if (casual.team.daily && (day_number.eql?(6) || day_number.eql?(0)))	
						@h75 = @ticking_day.number_of_hours
					end					
				end										
			else
				@ticking_displayed = 0
			end
		end
		@results_hash.merge!("ticking_displayed" => @ticking_displayed, "partialpp" => @pp, "partialh75" => @h75, "partialh100" => @h100)
		@results_hash
  end
  
end

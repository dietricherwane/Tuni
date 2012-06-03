# -*- encoding : utf-8 -*-
class Devise::UsersController < Devise::RegistrationsController
	prepend_before_filter :authenticate_user!
	before_filter :duke
	#layout :layout_used

	def search_ajax
		@params = params[:query].strip.split
    @searched_fields = ["firstname","lastname", "phone_number", "mobile_number"]   	
    @users = custom_ajax_search(@searched_fields, @params, User, params[:status]).paginate(:page => params[:page], :per_page => 10)    	
    @tr_color = true
    render :partial => "search_ajax" 
	end
	
	def custom_ajax_search(searched_fields, parameters, concerned_model, range)
    @res = "("
    @range_sql = " "
    @post_office_model = ["Direction", "Workshop", "Team"]
        
    case range
			when "enabled"
				@range_sql << "AND confirmation_token IS NULL"
			when "disabled"
				@range_sql << "AND confirmation_token IS NOT NULL"
			end  
			  
    parameters.each do |parameter| 
    	@office_container = ""
    	@res += " ("
    	   	
      searched_fields.each do |searched_field|
        @res += " "+searched_field+" ILIKE "+"'%"+parameter+"%'"+" OR"
      end  
      @res = @res.sub(/OR$/, '')
      
      #éléments de recherche pour les directions, ateliers, équipes
      @post_office_model.each do |post_office_model|
      	@por = post_office_model.constantize.where("#{post_office_model.downcase+"_name"} ILIKE "+"'%"+parameter+"%'")
      	if @por.empty?
      	else
      		@por.each do |por|
      			@office_container += "OR (status_number = #{por.id} AND status_id = #{Status.find_by_status_name(post_office_reverse(post_office_model)).id})"
      		end
      	end
      	
      end
      @res += @office_container

      #éléments de recherche pour les statuts
      @res += status_collector("status_name", "status_id", parameter, Status) 
      @res += ") AND"
    end
    if params[:query].empty?
    	case range
				when "all"
					User.all
				when "enabled"
					User.where("confirmation_token IS NULL")
				when "disabled"
					User.where("confirmation_token IS NOT NULL")
				end
    else
    	#concerned_model.where("#{@res.sub(/OR$/, '').sub(/OR $/, '') << ")" << @range_sql}")
    	concerned_model.where("#{@res.sub(/AND$/, '') << ")" << @range_sql}")  
    end
  end
  
  def status_collector(searched_field, searched_field_id, parameter, concerned_model)
  	@result = "OR"
  	@status = concerned_model.where("#{searched_field} ILIKE '%"+parameter+"%'")
  	unless @status.empty? 
  		@status.each do |stat|
  			@result += " #{searched_field_id} = #{stat.id}"+" OR"
  		end
  	end
  	@result.sub(/OR$/, '')
  end
  
  def post_office(status_name)
  	@post = ""
  	case status_name
  	when "Chef de direction"
  		@post = Direction
  	when "Chef d'atelier"
  		@post = Workshop
  	when "Chef d'équipe"
  		@post = Team
  	else
  		@post = "administrator"
  	end
  	@post
  end
  
  def post_office_reverse(model_name)
  	@post = ""
  	case model_name
  	when "Direction"
  		@post = "Chef de direction"
  	when "Workshop"
  		@post = "Chef d'atelier"
  	when "Team"
  		@post = "Chef d'équipe"
  	end
  	@post
  end
      
  def enable_user 
  	@user = User.find_by_id(params[:format])
  	@user_duplicated = User.where("status_id = #{@user.status_id} AND status_number = #{@user.status_number} AND confirmation_token IS NULL AND enabled IS NOT FALSE")
  	if @user_duplicated.empty?
  		@user.update_attribute(:enabled, true)
  		redirect_to dashboard_path, :notice => "Le compte de #{@user.firstname} #{@user.lastname} a été activé"
  	else
  		redirect_to :back, :alert => "#{@user_duplicated.first.firstname} #{@user_duplicated.first.lastname} est déjà #{@user_duplicated.first.status(@user_duplicated.first)}"
  	end  	
  end
  
  def disable_user
  	@user = User.find_by_id(params[:format])
  	@user.update_attribute(:enabled, false)
  	redirect_to dashboard_path, :notice => "Le compte de #{@user.firstname} #{@user.lastname} a été désactivé"
  end
  
  def delete_user
  	@user = User.find_by_id(params[:format])
  	@user_infos = "#{@user.firstname} #{@user.lastname} "
  	User.delete(@user.id)
  	redirect_to dashboard_path, :notice => "Le compte de #{@user_infos} a été supprimé"
  end
  
  def edit
    @user = User.find_by_id(params[:format])
    @statuses = Status.all 
    render_with_scope :edit
  end
  
  def update
    @user = User.find_by_id(params[:user][:user_id])
    @status = Status.find_by_id(params[:post][:status_id])
		@params_direction = params[:direction_name] == "-Veuillez choisir une direction-"
		@params_workshop = params[:workshop_name] == "-Veuillez choisir un atelier-"
		@params_team = params[:team_name] == "-Veuillez choisir une équipe-"
		@firstname = capitalization(params[:user][:firstname])
		@lastname = capitalization(params[:user][:lastname])
		@phone_number = params[:user][:phone_number]
		@mobile_number = params[:user][:mobile_number]

# Si le statut de l'utilisateur n'a pas été modifié.		
		if @status.eql?(nil)
			@user.update_attributes(:firstname => @firstname, :lastname => @lastname, :phone_number => @phone_number, :mobile_number => @mobile_number)
			redirect_to dashboard_path, :notice => "Le profil de #{@user.firstname} #{@user.lastname} a été mis à jour."
		else
			if ((@status.status_name.eql?("Chef de direction") && @params_direction) || (@status.status_name.eql?("Chef d'atelier") && (@params_direction || @params_workshop)) || (@status.status_name.eql?("Chef d'équipe") && (@params_direction || @params_workshop || @params_team)))
				#clean_up_passwords(resource)
				@statuses = Status.all
				flash[:alert] = "Veuillez correctement choisir le statut."
				render :action => 'edit'
			else
				if (@status.status_name.eql?("Chef de direction") || @status.status_name.eql?("Chef d'atelier") || @status.status_name.eql?("Chef d'équipe"))

#Empecher que deux utilisateurs du meme profil soient activés en meme temps (sauf admin et supadmin)
					@user_duplicated = User.where("status_id = #{@status.id} AND status_number = #{translate_status(@status.id, params[:direction_name], params[:workshop_name], params[:team_name])} AND confirmation_token IS NULL AND enabled IS NOT FALSE")
      		if @user_duplicated.empty?
      			@user.update_attributes(:firstname => @firstname, :lastname => @lastname, :phone_number => @phone_number, :mobile_number => @mobile_number, :status_id => @status.id, :status_number => translate_status(@status.id, params[:direction_name], params[:workshop_name], params[:team_name]))
      			redirect_to dashboard_path, :notice => "Le profil de #{@user.firstname} #{@user.lastname} a été mis à jour."
      		else
      			redirect_to :back, :alert => "#{@user_duplicated.first.firstname} #{@user_duplicated.first.lastname} est déjà #{@user_duplicated.first.status(@user_duplicated.first)}"
      		end
		    else
		    	@user.update_attributes(:firstname => @firstname, :lastname => @lastname, :phone_number => @phone_number, :mobile_number => @mobile_number, :status_id => @status.id, :status_number => nil)
		    	redirect_to dashboard_path, :notice => "Le profil de #{@user.firstname} #{@user.lastname} a été mis à jour."
		    end		    
			end
		end
  end
  
  def dae
  	@directions = Direction.all
  end
  
  def create_dae
  	@dae = params[:dae_name]
  	@direction = params[:direction_name]
  	@workshop = params[:workshop_name]
  	@section = params[:section_name]
  	@value = params[:valeur]
  	@element = ""
  	
  	if ((@dae.eql?("-Veuillez choisir un élément-")) || (@dae.eql?("Direction") && @value.empty?) || (@dae.eql?("Atelier") && (@direction.eql?("-Veuillez choisir une direction-") || @value.empty?)) || (@dae.eql?("Section") && (@direction.eql?("-Veuillez choisir une direction-") || @workshop.eql?("-Veuillez choisir un atelier-") || @value.empty?)) || (@dae.eql?("Ligne") && (@direction.eql?("-Veuillez choisir une direction-") || @workshop.eql?("-Veuillez choisir un atelier-") || @section.eql?("-Veuillez choisir une section-") || @value.empty?)) || (@dae.eql?("Equipe") && (@direction.eql?("-Veuillez choisir une direction-") || @workshop.eql?("-Veuillez choisir un atelier-") || @value.empty?)))
  		redirect_to dae_path, :alert => "Veuillez correctement choisir l'élément à créer."
  	else
  		case @dae
				when "Direction"
					if Direction.find_by_direction_name(capitalization(@value)).eql?(nil)
						Direction.create(:direction_name => capitalization(@value))
						dae_path_on_success("La direction:", capitalization(@value))
					else
						dae_path_on_failure("Une direction du même nom existe déjà.")
					end
				when "Atelier"
					if Workshop.where("direction_id = #{Direction.find_by_direction_name(@direction).id} AND workshop_name = '#{capitalization(@value)}'").empty?
						Direction.find_by_direction_name(@direction).workshops.create(:workshop_name => capitalization(@value))
						dae_path_on_success("L'atelier:", capitalization(@value))
					else
						dae_path_on_failure("Un atelier du même nom existe déjà dans cette direction.")
					end
				when "Section"
					if Section.where("workshop_id = #{Workshop.find_by_workshop_name(@workshop).id} AND section_name = '#{capitalization(@value)}'").empty?
						Workshop.find_by_workshop_name(@workshop).sections.create(:section_name => capitalization(@value))
						dae_path_on_success("La section:", capitalization(@value))
					else
						dae_path_on_failure("Une section du même nom existe déjà dans l'atelier.")
					end
				when "Ligne"
					if Line.where("section_id = #{Section.find_by_section_name(@section).id} AND line_name = '#{capitalization(@value)}'").empty?
						Section.find_by_section_name(@section).lines.create(:line_name => capitalization(@value), :max_number_of_casuals => 10)
						dae_path_on_success("La ligne:", capitalization(@value))
					else
						dae_path_on_failure("Une ligne du même nom existe déjà dans la section.")
					end
				when "Equipe"
					if Team.where("workshop_id = #{Workshop.find_by_workshop_name(@workshop).id} AND team_name = '#{capitalization(@value)}'").empty?
						params[:daily][:answer].eql?("no") ? @daily = false : @daily = true
						Workshop.find_by_workshop_name(@workshop).teams.create(:team_name => capitalization(@value), :max_number_of_casuals => 30, :number_of_operators => 2, :daily => @daily)
						dae_path_on_success("L'équipe:", capitalization(@value))
					else
						dae_path_on_failure("Une équipe du même nom existe déjà dans l'atelier.")
					end
				end 	
  	end
  end
  
  def dae_path_on_success(element, value)
  	redirect_to dae_path, :notice => "#{element} #{value} a été(e) créé(e)."
  end
  
  def dae_path_on_failure(message)
  	redirect_to dae_path, :alert => message
  end
  
  def change_to_daily_or_normal
  	@team = Team.find(params[:format].to_i)
  	if @team.daily
  		@team.update_attribute(:daily, false)
  		@message = "#{@team.team_name}: a été changée en équipe normale."
  	else
  		@team.update_attribute(:daily, true)
  		@message = "#{@team.team_name}: a été changée en équipe journalière."
  	end
  	redirect_to :back, :notice => @message
  end
	
end

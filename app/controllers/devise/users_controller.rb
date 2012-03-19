# -*- encoding : utf-8 -*-
class Devise::UsersController < Devise::RegistrationsController

	def search_ajax
		@params = params[:query].strip.split
    @searched_fields = ["firstname","lastname", "phone_number", "mobile_number"]
    @users_safe = []
    if params[:status] == "all"    	
    	@users = custom_ajax_search(@searched_fields, @params, User, params[:status]).paginate(:page => params[:page], :per_page => 10)    	
    end    
    if params[:status] == "enabled"
    	@users = custom_ajax_search(@searched_fields, @params, User, params[:status]).delete(current_user.id).paginate(:page => params[:page], :per_page => 10)    	
    end    
    if params[:status] == "disabled"
    	@users = custom_ajax_search(@searched_fields, @params, User, params[:status]).delete(current_user.id).paginate(:page => params[:page], :per_page => 10)   	
    end  
    @tr_color = true
    #render :layout => false
    render :partial => "search_ajax" 
	end
	
	def custom_ajax_search(searched_fields, parameters, concerned_model, range)
    @res = "("
    @range_sql = " "
    @post_office_model = ["Direction", "Workshop", "Team"]
    @post_office = ""
    @office_container = ""
    case range
			when "all"
			
			when "enabled"
				@range_sql << "AND confirmation_token IS NULL"
			when "disabled"
				@range_sql << "AND confirmation_token IS NOT NULL"
			end    
    parameters.each do |parameter|

    	
      searched_fields.each do |searched_field|
        @res += " "+searched_field+" ILIKE "+"'%"+parameter+"%'"+" OR"
      end  
      
      @post_office_model.each do |post_office_model|
      	@por = post_office_model.constantize.where("#{post_office_model.downcase+"_name"} ILIKE "+"'%"+parameter+"%'")
      	if @por.empty?
      	else
      		@por.each do |por|
      			@office_container += "(status_number = #{por.id} AND status_id = #{Status.find_by_status_name(post_office_reverse(post_office_model)).id}) OR"
      		end
      	end
      end
      @res += @office_container

      #pour les statuts
      @res += status_collector("status_name", "status_id", parameter, Status) 
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
    	concerned_model.where("#{@res.sub(/OR$/, '').sub(/OR $/, '') << ")" << @range_sql}")  
    end
  end
  
  def status_collector(searched_field, searched_field_id, parameter, concerned_model)
  	@result = ""
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
  	@user.update_attribute(:enabled, true)
  	redirect_to dashboard_path, :alert => "Le compte de #{@user.lastname} #{@user.firstname} a été activé"
  end
  
  def disable_user
  	@user = User.find_by_id(params[:format])
  	@user.update_attribute(:enabled, false)
  	redirect_to dashboard_path, :alert => "Le compte de #{@user.lastname} #{@user.firstname} a été désactivé"
  end
  
  def delete_user
  	@user = User.find_by_id(params[:format])
  	@user_infos = "#{@user.lastname} #{@user.firstname}"
  	User.delete(@user.id)
  	redirect_to dashboard_path, :alert => "Le compte de #{@user_infos} a été supprimé"
  end
  
  def edit
    @user = User.find_by_id(params[:format])
    @statuses = Status.all 
    render_with_scope :edit
  end
  
  def update
    @user = User.find_by_id(params[:user][:user_id])
    @status = Status.find_by_id(params[:post][:status_id])
		@params_direction = params[:direction_name].eql?("-Veuillez choisir une direction-")
		@params_workshop = params[:workshop_name].eql?("-Veuillez choisir un atelier-")
		@params_team = params[:team_name].eql?("-Veuillez choisir une équipe-")
		@firstname = capitalization(params[:user][:firstname])
		@lastname = capitalization(params[:user][:lastname])
		@phone_number = params[:user][:phone_number]
		@mobile_number = params[:user][:mobile_number]
		
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
      	@user.update_attributes(:firstname => @firstname, :lastname => @lastname, :phone_number => @phone_number, :mobile_number => @mobile_number, :status_id => @status.id, :status_number => translate_status(@status.id, params[:direction_name], params[:workshop_name], params[:team_name]))
		    else
		    	@user.update_attributes(:firstname => @firstname, :lastname => @lastname, :phone_number => @phone_number, :mobile_number => @mobile_number, :status_id => @status.id, :status_number => nil)
		    end
		    redirect_to dashboard_path, :notice => "Le profil de #{@user.firstname} #{@user.lastname} a été mis à jour."
			end
		end
  end
  
  def dae
  	
  end
  
  def create_dae
  	@dae = params[:dae_name]
  	@direction = params[:direction_name]
  	@workshop = params[:workshop_name]
  	@section = params[:section_name]
  	@value = params[:valeur]
  	@element = ""
  	
  	if ((@dae.eql?("-Veuillez choisir un élément-")) || (@dae.eql?("Direction") && @value.empty?) || (@dae.eql?("Atelier") && (@direction.eql?("-Veuillez choisir une direction-") || @value.empty?)) || (@dae.eql?("Section") && (@direction.eql?("-Veuillez choisir une direction-") || @workshop.eql?("-Veuillez choisir un atelier-") || @value.empty?)) || (@dae.eql?("Ligne") && (@direction.eql?("-Veuillez choisir une direction-") || @workshop.eql?("-Veuillez choisir un atelier-") || @section.eql?("-Veuillez choisir une section-") || @value.empty?)) || (@dae.eql?("Equipe") && (@direction.eql?("-Veuillez choisir une direction-") || @workshop.eql?("-Veuillez choisir un atelier-") || @value.empty?)))
  		redirect_to dae_path, :notice => "Veuillez correctement choisir l'élément à créer."
  	else
  		case @dae
				when "Direction"
					Direction.create(:direction_name => capitalization(@value))
					@element = "La direction:"
				when "Atelier"
					Direction.find_by_direction_name(@direction).workshops.create(:workshop_name => capitalization(@value))
					@element = "L'atelier:"
				when "Section"
					Workshop.find_by_workshop_name(@workshop).sections.create(:section_name => capitalization(@value))
					@element = "La section:"
				when "Ligne"
					Section.find_by_section_name(@section).lines.create(:line_name => capitalization(@value))
					@element = "La ligne:"
				when "Equipe"
					Workshop.find_by_workshop_name(@workshop).teams.create(:team_name => capitalization(@value))
					@element = "L'équipe:"
				end 
			redirect_to dae_path, :notice => "#{@element} #{capitalization(@value)} a été(e) créé(e)." 		
  	end
  end
	
end

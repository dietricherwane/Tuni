# -*- encoding : utf-8 -*-
class Devise::RegistrationsController < ApplicationController
  #prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  #prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  include Devise::Controllers::InternalHelpers
  before_filter :logout_disabled_user
  layout :layout_used
  
  # GET /resource/sign_up
  def new
  	#if user_signed_in?
		  resource = build_resource({})
		 	@statuses = Status.all 
		  respond_with_navigational(resource){ render_with_scope :new }
    #else
    	#redirect_to new_user_session_path, :alert => "Veuillez d'abord vous connecter."
    #end
  end
  
  # POST /resource
  def create
    build_resource
    @status = Status.find_by_id(params[:post][:status_id])
		@params_direction = params[:direction_name].eql?("-Veuillez choisir une direction-")
		@params_workshop = params[:workshop_name].eql?("-Veuillez choisir un atelier-")
		@params_team = params[:team_name].eql?("-Veuillez choisir une équipe-")
		@firstname = capitalization(params[:user][:firstname])
		@lastname = capitalization(params[:user][:lastname])
	
		if (@status.eql?(nil) || (@status.status_name.eql?("Chef de direction") && @params_direction) || (@status.status_name.eql?("Chef d'atelier") && (@params_direction || @params_workshop)) || (@status.status_name.eql?("Chef d'équipe") && (@params_direction || @params_workshop || @params_team)))
			clean_up_passwords(resource)
		  @statuses = Status.all
		  flash[:alert] = "Veuillez correctement choisir le statut."
		  respond_with_navigational(resource) { render_with_scope :new }
		else
		  if resource.save
		    if resource.active_for_authentication?
		      set_flash_message :notice, :signed_up if is_navigational_format?
		      sign_in(resource_name, resource)
		      respond_with resource, :location => after_sign_up_path_for(resource)
		    else
		      set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?	      
		      if (@status.status_name.eql?("Chef de direction") || @status.status_name.eql?("Chef d'atelier") || @status.status_name.eql?("Chef d'équipe"))
		      	resource.update_attributes(:firstname => @firstname, :lastname => @lastname, :status_id => @status.id, :status_number => translate_status(@status.id, params[:direction_name], params[:workshop_name], params[:team_name]))
		      else
		      	resource.update_attributes(:firstname => @firstname, :lastname => @lastname, :status_id => @status.id)
		      end
		      expire_session_data_after_sign_in!
		      redirect_to new_user_registration_path
		      #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
		    end
		  else
		    clean_up_passwords(resource)
		    @statuses = Status.all
		    respond_with_navigational(resource) { render_with_scope :new }
		  end
		end
  end

  # GET /resource/edit
  def edit
    render_with_scope :edit
  end
  
  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_with_password(params[resource_name])
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource){ render_with_scope :edit }
    end
  end

  # DELETE /resource
  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_registration_path(resource_name)
  end
  
  def get_directions
  	@directions_options = "<option>-Veuillez choisir une direction-</option>"
  	Direction.all.each do |direction|
  		@directions_options << "<option>#{direction.direction_name}</option>"
  	end  	
    render :text => @directions_options
  end
  
  def get_workshops
  	@selected_direction = params.first.first
  	@workshops_options = "<option>-Veuillez choisir un atelier-</option>"
		@workshops = Direction.find_by_direction_name(@selected_direction).workshops
		@workshops.each do |workshop|
			@workshops_options << "<option>#{workshop.workshop_name}</option>"
		end
  	render :text => @workshops_options
  end
  
  def get_sections
  	@selected_workshop = params.first.first
  	@sections_options = "<option>-Veuillez choisir une section-</option>"
		@sections = Workshop.find_by_workshop_name(@selected_workshop).sections
		@sections.each do |section|
			@sections_options << "<option>#{section.section_name}</option>"
		end
  	render :text => @sections_options
  end
  
  def get_teams
  	@selected_workshop = params.first.first
  	@teams_options = "<option>-Veuillez choisir une équipe-</option>"
  	@teams = Workshop.find_by_workshop_name(@selected_workshop).teams.where("daily IS NOT TRUE")
  	@teams.each do |team|
  		@teams_options << "<option>#{team.team_name}</option>"
  	end
  	render :text => @teams_options
  end
  
  def get_all_teams
  	@selected_workshop = params.first.first
  	@teams_options = "<option>-Veuillez choisir une équipe-</option>"
  	@teams = Workshop.find_by_workshop_name(@selected_workshop).teams
  	@teams.each do |team|
  		@teams_options << "<option>#{team.team_name}</option>"
  	end
  	render :text => @teams_options
  end
  
  

  protected

    # Build a devise resource passing in the session. Useful to move
    # temporary session data to the newly created user.
    def build_resource(hash=nil)
      hash ||= params[resource_name] || {}
      self.resource = resource_class.new_with_session(hash, session)
    end

    # The path used after sign up. You need to overwrite this method
    # in your own RegistrationsController.
    def after_sign_up_path_for(resource)    	
      after_sign_in_path_for(resource)
    end

    # Returns the inactive reason translated.
    def inactive_reason(resource)
      reason = resource.inactive_message.to_s
      I18n.t("devise.registrations.reasons.#{reason}", :default => reason)
    end

    # The path used after sign up for inactive accounts. You need to overwrite
    # this method in your own RegistrationsController.    
    def after_inactive_sign_up_path_for(resource)
      root_path
    end

    # The default url to be used after updating a resource. You need to overwrite
    # this method in your own RegistrationsController.
    def after_update_path_for(resource)
      dashboard_path#signed_in_root_path(resource)
    end

    # Authenticates the current scope and gets the current resource from the session.
    def authenticate_scope!
      send(:"authenticate_#{resource_name}!", :force => true)
      self.resource = send(:"current_#{resource_name}")
    end
    
end

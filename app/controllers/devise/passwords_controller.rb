# -*- encoding : utf-8 -*-
class Devise::PasswordsController < ApplicationController
	#before_filter :change_password, :exept => :new
  #prepend_before_filter :require_no_authentication
  include Devise::Controllers::InternalHelpers

  # GET /resource/password/new
  def new
    build_resource({})
    render_with_scope :new
  end

  # POST /resource/password
  def create
  	if user_signed_in?
    	sign_out(current_user)
    end
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if successfully_sent?(resource)
    	#if (current_user.sign_in_count.eql?(1) && (current_user.reset_password_token != nil))
    	#redirect_to new_user_session_path, :alert => "Un email vient de vous être envoyé avec un lien pour changer votre mot de passe."
    	#else
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
      #end
    else
      respond_with_navigational(resource){ render_with_scope :new }
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    render_with_scope :edit
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)

      #respond_with resource, :location => after_sign_in_path_for(resource)
      redirect_to dashboard_administrator_path#, :alert => "Votre mot de passe a été changé."

    else
      respond_with_navigational(resource){ render_with_scope :edit }
    end
  end

  protected

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name)
    end

end
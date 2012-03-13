# -*- encoding : utf-8 -*-
class FakeController < ApplicationController
	before_filter :change_password
  def index
  	if user_signed_in?
		  redirect_to dashboard_path
    else
    	redirect_to new_user_session_path#, :alert => "Veuillez d'abord vous connecter."
    	#redirect_to new_user_password_path, :alert => "back"
    end
  end

end

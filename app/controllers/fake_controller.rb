# -*- encoding : utf-8 -*-
class FakeController < ApplicationController
	
  def index
  	if user_signed_in?
		  redirect_to dashboard_path
    else
    	redirect_to new_user_session_path, :alert => "Vous ne pouvez pas accéder à cette ressource."
    end
  end

end

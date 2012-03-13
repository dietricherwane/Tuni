# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def change_password
  	if user_signed_in?
			if (current_user.sign_in_count.eql?(1) && current_user.reset_password_token.eql?(nil))
				redirect_to new_user_password_path
			end
			if (current_user.sign_in_count.eql?(1) && (current_user.reset_password_token != nil))
				redirect_to new_user_session_path, :alert => "Un email vient de vous être envoyé avec un lien pour changer votre mot de passe."
			end
		end
  end
  
end

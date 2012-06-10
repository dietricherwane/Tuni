# -*- encoding : utf-8 -*-
class FakeController < ApplicationController
	before_filter :change_password
	layout :layout_used
	
  def index
  	@status = current_user_status
  	case @user_status
			when 'Administrateur'
				redirect_to dashboard_path
			when 'Chef de direction'
				redirect_to dashboard_path
			when "Chef d'atelier"
				redirect_to allot_casual_to_team_path
			when "Chef d'équipe"
				redirect_to allot_to_line_path
			else
				redirect_to new_user_session_path
			end
  end

end

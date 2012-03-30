# -*- encoding : utf-8 -*-
class TeamsController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_used
	
  def number_of_casuals
  end

end

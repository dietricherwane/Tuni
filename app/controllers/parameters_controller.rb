# -*- encoding : utf-8 -*-
class ParametersController < ApplicationController

	def set_holidays
		@message = ''
		@holiday = Date.new(params[:select][:"holiday(1i)"].to_i, params[:select][:"holiday(2i)"].to_i, params[:select][:"holiday(3i)"].to_i)
		if @holiday < Date.today
			redirect_to :back, :alert => "Veuillez choisir un jour futur."
		else
			if Holiday.find_by_holiday(@holiday).nil?
				Holiday.create(:week_number => @holiday.cweek, :holiday => @holiday, :user_id => current_user.id)
				redirect_to :back, :notice => "Le #{@holiday.strftime("%d %B %Y")} est désormais férié."
			else
				redirect_to :back, :alert => "Le #{@holiday.strftime("%d %B %Y")} est déjà férié."
			end
		end
	end

end

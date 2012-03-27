# -*- encoding : utf-8 -*-
class CitiesController < ApplicationController

	def create
		if (params[:city_name].empty? || params[:short_name].empty?)
			redirect_to casuals_settings_path, :alert => "Création de ville: Veuillez entrer le nom de la ville ainsi que son abbréviation."
		else
			@city = capitalization(params[:city_name])
			@short_name = params[:short_name].upcase
			if City.find_by_city_name(@city).eql?(nil) && City.find_by_short_name(@short_name).eql?(nil)
				City.create(:city_name => @city, :short_name => @short_name)
				redirect_to casuals_settings_path, :notice => "La ville: #{@city} ayant pour abbréviation #{@short_name} a été créée."
			else
				redirect_to casuals_settings_path, :alert => "Cette ville ou cette abbréviation existe déjà."
			end
		end
	end	
	
end

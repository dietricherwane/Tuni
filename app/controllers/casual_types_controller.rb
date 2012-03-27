# -*- encoding : utf-8 -*-
class CasualTypesController < ApplicationController

	def create
		@type_name = params[:type_name]
		@prime = params[:prime]
		@hourly_rate = params[:hourly_rate]
		@months_number = params[:months_number]
		@max_months_number = params[:max_months_number]
		@delay_before_return = params[:delay_before_return]
		
		if (@type_name.empty? || @prime.empty? || @hourly_rate.empty? || @months_number.empty? || @max_months_number.empty? || @delay_before_return.empty?)
			redirect_to casuals_settings_path, :alert => "Création de type de temporaire: Veuillez remplir tous les champs."
		else
			if CasualType.find_by_type_name(capitalization(@type_name)).eql?(nil)
				if (@prime.to_i <= 0 || @hourly_rate.to_i <= 0 || @months_number.to_i <= 0 || @max_months_number.to_i <= 0 || @delay_before_return <= 0)
				redirect_to casuals_settings_path, :alert => "La prime, le taux horaire, le nombre de mois, le délai avant retour doivent être des nombres supérieurs à 0."
				else
					if @max_months_number.to_i.remainder(@months_number.to_i) != 0
						redirect_to casuals_settings_path, :alert => "Le nombre maximal de mois doit être supérieur au nombre de mois et ils doivent être multiples."
					else
						CasualType.create(:type_name => capitalization(@type_name), :prime => @prime.to_i, :hourly_rate => @hourly_rate.to_i, :months_number => @months_number.to_i, :max_months_number => @max_months_number.to_i, :delay_before_return => @delay_before_return.to_i)
					end
				end
			else
				redirect_to casuals_settings_path, :alert => "Ce type de temporaire existe déjà."
			end
		end
	end	
	
end

# -*- encoding : utf-8 -*-
class CompaniesController < ApplicationController

	def create
		if params[:company_name].empty?
			redirect_to casuals_settings_path, :alert => "Création de compagnie: Veuillez entrer un nom de compagnie."
		else
			@company = params[:company_name].upcase
			if Company.find_by_company_name(@company).eql?(nil)
				Company.create(:company_name => @company)
				redirect_to casuals_settings_path, :notice => "La compagnie: #{@company} a été créée."
			else
				redirect_to casuals_settings_path, :alert => "La compagnie: #{@company} existe déjà."
			end
		end
	end

end

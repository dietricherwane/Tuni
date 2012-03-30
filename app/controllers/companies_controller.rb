# -*- encoding : utf-8 -*-
class CompaniesController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_used

	def create
		if params[:company_name].empty?
			redirect_to casuals_settings_path, :alert => "Création de compagnie: Veuillez entrer un nom de compagnie."
		else
			@company = params[:company_name].upcase
			if Company.find_by_company_name(@company).eql?(nil)
				if @company.size > 2
					Company.create(:company_name => @company)
					redirect_to casuals_settings_path, :notice => "La compagnie: #{@company} a été créée."
				else
					redirect_to :back, :alert => "Le nom de la compagnie doit être supérieur à 2 caractères."
				end
			else
				redirect_to casuals_settings_path, :alert => "La compagnie: #{@company} existe déjà."
			end
		end
	end

end

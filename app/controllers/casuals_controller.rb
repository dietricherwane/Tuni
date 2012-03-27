# -*- encoding : utf-8 -*-
class CasualsController < ApplicationController

	def casuals_settings
		@cities = City.all.paginate(:page => params[:page], :per_page => 15)
		@companies = Company.all.paginate(:page => params[:page], :per_page => 15)
		@casual_types = CasualType.all.paginate(:page => params[:page], :per_page => 15)
		@tr_color = true
	end
	
	def new
		@casuals = Casual.all.paginate(:page => params[:page], :per_page => 15)
		@casual = Casual.new
		@companies = Company.all
		@cities = City.all
		@casual_types = CasualType.all
		@directions = Direction.all
	end
	
	def create
		@firstname = params[:casual][:firstname]
		@lastname = params[:casual][:lastname]
		@birthdate = Date.new(params[:casual][:"birthdate(1i)"].to_i, params[:casual][:"birthdate(2i)"].to_i, params[:casual][:"birthdate(3i)"].to_i)
		@birthdate_for_identifier = params[:casual][:"birthdate(3i)"]+params[:casual][:"birthdate(2i)"]+params[:casual][:"birthdate(1i)"]
		@identifier = params[:casual][:identifier]
		@city_id = params[:post][:city_id]
		@company_id = params[:post][:company_id]
		@casual_type_id = params[:post][:casual_type_id]
		@direction_id = params[:post][:direction_id]
		@workshop = params[:workshop_name]
		
		if (@firstname.eql?(nil) || @lastname.eql?(nil) || @identifier.eql?(nil) || @city_id.eql?(nil) || @company_id.eql?(nil) || @casual_type_id.eql?(nil) || @direction_id.eql?(nil) || @workshop.eql?("-Veuillez choisir un atelier-") || @workshop.eql?(nil))
			redirect_to new_casual_path, :alert => "Veuillez correctement remplir les champs."
		else
			Casual.create(:firstname => capitalization(@firstname), :lastname => capitalization(@lastname), :birthdate => @birthdate, :identifier => "#{@identifier+@birthdate_for_identifier+City.find_by_id(@city_id.to_i).short_name}", :city_id => @city_id.to_i, :company_id => @company_id.to_i, :casual_type_id => @casual_type_id.to_i, :workshop_id => Workshop.find_by_workshop_name(@workshop).id)
			Casual.last.migration_dates.create(:entrance_date => Date.today.beginning_of_week)
			redirect_to new_casual_path, :notice => "Le temporaire #{capitalization(@firstname)} #{capitalization(@lastname)} a été créé."
		end
	end
	
	def get_workshops
  	@selected_direction = params.first.first
  	@workshops_options = "<option>-Veuillez choisir un atelier-</option>"
		@workshops = Direction.find_by_direction_name(@selected_direction).workshops
		@workshops.each do |workshop|
			@workshops_options << "<option>#{workshop.workshop_name}</option>"
		end
  	render :text => @workshops_options
  end
	
end

# -*- encoding : utf-8 -*-
class CasualsController < ApplicationController
	before_filter :authenticate_user!
	layout :layout_used

	def casuals_settings
		@cities = City.all.paginate(:page => params[:page], :per_page => 15)
		@companies = Company.all.paginate(:page => params[:page], :per_page => 15)
		@casual_types = CasualType.all.paginate(:page => params[:page], :per_page => 15)
		@tr_color = true
	end

	def new
		@casual = Casual.new
		@companies = Company.all
		@cities = City.all
		@casual_types = CasualType.all
		@directions = Direction.all
	end
	
	def create
		@firstname = params[:casual][:firstname]
		@lastname = params[:casual][:lastname]
		@phone_number = params[:casual][:phone_number]
		@birthdate = Date.new(params[:casual][:"birthdate(1i)"].to_i, params[:casual][:"birthdate(2i)"].to_i, params[:casual][:"birthdate(3i)"].to_i)
		@identifier = params[:casual][:identifier]
		@city_id = params[:post][:city_id]
		@company_id = params[:post][:company_id]
		@casual_type_id = params[:post][:casual_type_id]
		@direction_id = params[:post][:direction_id]
		@workshop = params[:workshop_name]
		
		if (@firstname.eql?(nil) || @lastname.eql?(nil) || is_not_a_number?(@identifier) || @city_id.eql?(nil) || @company_id.eql?(nil) || @casual_type_id.eql?(nil) || @direction_id.eql?(nil) || @workshop.eql?("-Veuillez choisir un atelier-") || @workshop.eql?(nil))
			redirect_to :back, :alert => "Veuillez correctement remplir les champs."
		else
			if (@phone_number.empty? || (@phone_number.size.eql?(8) && !is_not_a_number?(@phone_number)))				

					if Casual.find_by_identifier("#{@identifier+City.find_by_id(@city_id.to_i).short_name}").eql?(nil)
					if Workshop.find_by_workshop_name(@workshop).max_number_of_casuals <= Casual.where("workshop_id = #{Workshop.find_by_workshop_name(@workshop).id}").count
						redirect_to :back, :alert => "Vous avez atteint le nombre maximal de personnes pouvant être affectées dans l'atelier: #{@workshop}."
					else
						Casual.create(:firstname => capitalization(@firstname), :lastname => capitalization(@lastname), :phone_number => @phone_number, :birthdate => @birthdate, :identifier => "#{@identifier+City.find_by_id(@city_id.to_i).short_name}", :city_id => @city_id.to_i, :company_id => @company_id.to_i, :casual_type_id => @casual_type_id.to_i, :workshop_id => Workshop.find_by_workshop_name(@workshop).id)
					# lié au defaultscope de Casual
						Casual.first.migration_dates.create(:entrance_date => Date.today.beginning_of_week)
						redirect_to :back, :notice => "Le temporaire #{capitalization(@firstname)} #{capitalization(@lastname)} a été créé."
					end
				else
					redirect_to :back, :alert => "Un temporaire portant ce matricule existe déjà."
				end

			else
				redirect_to :back, :alert => "Le numéro de téléphone doit être un nombre de 8 chiffres."
			end
		end
	end
	
	def search_ajax
		@params = params[:query].strip.split
    @searched_fields = ["firstname","lastname", "phone_number"]  	
    @casuals = custom_ajax_search(@searched_fields, @params, Casual, params[:status]).paginate(:page => params[:page], :per_page => 10)    	 
    @tr_color = true
    @user_to_be_affected = ""
    @directions = Direction.all    
    render :partial => "search_ajax"
	end
	
	def custom_ajax_search(searched_fields, parameters, concerned_model, range)
    @res = "("
    @range_sql = " "
    @post_office_model = ["Direction", "Workshop", "Team"]
        
    case range
			when "expired"
				@range_sql << "AND expired = true"
			when "retired"
				@range_sql << "AND retired_from_ticking = true"
			end   
			 
    parameters.each do |parameter| 
    	@directions_container = ""
		  @workshops_container = ""
		  @teams_container = ""
		  @companies_container = ""
		  @casual_types_container = ""
       
    	@res += " ("    	   	
      searched_fields.each do |searched_field|
        @res += " "+searched_field+" ILIKE "+"'%"+parameter+"%'"+" OR"
      end  
      @res = @res.sub(/OR$/, '')
      
      #éléments de recherche pour les directions
    	@directions = Direction.where("direction_name ILIKE "+"'%"+parameter+"%'")
    	if @directions.empty?
    	else
    		@directions.each do |direction|
    			if direction.workshops.empty?
    			else
    				direction.workshops.each do |workshop|
    					@directions_container += "OR workshop_id = #{workshop.id} "
    				end
    			end
    		end
    	end
    	@res += @directions_container
    	
    	#éléments de recherche pour les ateliers
    	@workshops = Workshop.where("workshop_name ILIKE "+"'%"+parameter+"%'")
    	if @workshops.empty?
    	else
    		@workshops.each do |workshop|
    			@workshops_container += "OR workshop_id = #{workshop.id} "
    		end
    	end
    	@res += @workshops_container
    	
    	#éléments de recherche pour les équipes
    	@teams = Team.where("team_name ILIKE "+"'%"+parameter+"%'")
    	if @teams.empty?
    	else
    		@teams.each do |team|
    			@teams_container += "OR team_id = #{team.id} "
    		end
    	end
    	@res += @teams_container
    	
    	#éléments de recherche pour les compagnies
    	@companies = Company.where("company_name ILIKE "+"'%"+parameter+"%'")
    	if @companies.empty?
    	else
    		@companies.each do |company|
    			@companies_container += "OR company_id = #{company.id} "
    		end
    	end
    	@res += @companies_container
    	
    	#éléments de recherche pour les types de temporaires
    	@casual_types = CasualType.where("type_name ILIKE "+"'%"+parameter+"%'")
    	if @casual_types.empty?
    	else
    		@casual_types.each do |casual_type|
    			@casual_types_container += "OR casual_type_id = #{casual_type.id} "
    		end
    	end
    	@res += @casual_types_container
    	
    	#éléments de recherche par matricule
    	@res += "OR identifier ILIKE "+"'%"+parameter+"%'"
    	
    	
    	@res += @teams_container
      @res += ") AND"
    end
    
    if params[:query].empty?
    	case range
				when "all"
					Casual.all
				when "expired"
					Casual.where("expired = true")
				when "retired"
					Casual.where("retired_from_ticking = true")
				end
    else
    	#concerned_model.where("#{@res.sub(/OR$/, '').sub(/OR $/, '') << ")" << @range_sql}")
    	concerned_model.where("#{@res.sub(/AND$/, '') << ")" << @range_sql}")  
    end
  end
  
  def status_collector(searched_field, searched_field_id, parameter, concerned_model)
  	@result = "OR"
  	@status = concerned_model.where("#{searched_field} ILIKE '%"+parameter+"%'")
  	unless @status.empty? 
  		@status.each do |stat|
  			@result += " #{searched_field_id} = #{stat.id}"+" OR"
  		end
  	end
  	@result.sub(/OR$/, '')
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
  
  #Allocation of casual to workshop
  def allot_to_workshop
  	@direction_id = params[:wa][:direction_id]
  	@workshop_name = params[:wa_workshop_name]
  	
  	if @direction_id.empty? || @workshop_name.eql?("-Veuillez choisir un atelier-")
  		redirect_to :back, :alert => "Veuillez choisir une direction et un atelier dans lequel affecter le temporaire."
  	else
  		@casual = Casual.find(params[:casual_id].to_i)
  		@workshop = Workshop.find_by_workshop_name(@workshop_name)
  		@casuals_in_workshop = Casual.where("workshop_id = #{@workshop.id} AND expired IS NOT TRUE").count
  		@max_number_of_casuals = Team.find_by_sql("SELECT SUM(max_number_of_casuals + number_of_operators) AS number_of_casuals_in_workshop FROM teams WHERE workshop_id = #{@workshop.id};").first.number_of_casuals_in_workshop.to_i
  		
  		if @casuals_in_worksho.eql?(@max_number_of_casuals)
  			redirect_to :back, :alert => "Le nombre maximal de temporaires de l'atelier: #{@worksop_name} qui est de: #{@casuals_in_workshop} a été atteint."
  		else
				@casual.update_attributes(:workshop_id => @workshop.id, :retired_from_ticking => false)
				redirect_to :back, :notice => "#{@casual.firstname+" "+@casual.lastname} a été affecté à l'atelier #{@workshop_name}. #{@max_number_of_casuals}"
			end
  	end
  end
	
end

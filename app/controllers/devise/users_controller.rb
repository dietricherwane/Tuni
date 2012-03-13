# -*- encoding : utf-8 -*-
class Devise::UsersController < ApplicationController

	def search_ajax
		@params = params[:query].strip.split
    @searched_fields = ["firstname","lastname", "phone_number", "mobile_number"]
    if params[:status] == "all"    	
    	@users = custom_ajax_search(@searched_fields, @params, User, params[:status]).paginate(:page => params[:page], :per_page => 10)    	
    end    
    if params[:status] == "enabled"
    	@users = custom_ajax_search(@searched_fields, @params, User, params[:status]).paginate(:page => params[:page], :per_page => 10)    	
    end    
    if params[:status] == "disabled"
    	@users = custom_ajax_search(@searched_fields, @params, User, params[:status]).paginate(:page => params[:page], :per_page => 10)   	
    end  
    @tr_color = true
    render :partial => "search_ajax" 
	end
	
	def custom_ajax_search(searched_fields, parameters, concerned_model, range)
    @res = "("
    @range_sql = " "
    @post_office_model = [Direction, Workshop, Team]
    @post_office = ""
    case range
			when "all"
			
			when "enabled"
				@range_sql << "AND confirmation_token IS NULL"
			when "disabled"
				@range_sql << "AND confirmation_token IS NOT NULL"
			end    
    parameters.each do |parameter|
      searched_fields.each do |searched_field|
        @res << " "+searched_field+" ILIKE "+"'%"+parameter+"%'"+" OR"
      end  
      @post_office_model.each do |post_office_model|
      	@post_office = status_collector(post_office_model.to_s.downcase+"_name", "status_number", parameter, post_office_model)
      	@res <<  @post_office << " OR" unless @post_office.empty?
      end
      #pour les statuts
      @res << status_collector("status_name", "status_id", parameter, Status) << " OR"
    end
    if params[:query].empty?
    	case range
				when "all"
					User.all
				when "enabled"
					User.where("confirmation_token IS NULL")
				when "disabled"
					User.where("confirmation_token IS NOT NULL")
				end
    else
    	concerned_model.where("#{@res.sub(/OR$/, '').sub(/OR $/, '') << ")" << @range_sql}")  
    end
  end
  
  def status_collector(searched_field, searched_field_id, parameter, concerned_model)
  	@result = ""
  	@status = concerned_model.where("#{searched_field} ILIKE '%"+parameter+"%'")
  	unless @status.empty? 
  		@status.each do |stat|
  			@result << " #{searched_field_id} = #{stat.id}"+" OR"
  		end
  	end
  	@result.sub(/OR$/, '')
  end
  
  def post_office(status_name)
  	@post = ""
  	case status_name
  	when "Chef de direction"
  		@post = Direction
  	when "Chef d'atelier"
  		@post = Workshop
  	when "Chef d'équipe"
  		@post = Team
  	else
  		@post = "administrator"
  	end
  	@post
  end
	
end

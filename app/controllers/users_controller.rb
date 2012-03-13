class UsersController < ApplicationController

	def search_ajax
		@params = params[:query].strip.split
    @searched_fields = ["firstname","lastname", "phone_number", "mobile_number"]
    if params[:status] == "all"
    	@users = custom_ajax_search(@searched_fields, @params, User)
    	render :partial => "search_ajax"
    end
    
    if params[:status] == "enabled"
    
    end
    
    if params[:status] == "disabled"
    
    end   
	end
	
	def custom_ajax_search(searched_fields, parameters, concerned_model)
    @res = ""
    parameters.each do |parameter|
      searched_fields.each do |searched_field|
        @res << " "+searched_field+" ILIKE "+"'%"+parameter+"%'"+" OR"
      end  
      @res << status_collector("status_name", "status_id", parameter, Status)
    end
    concerned_model.where("#{@res.sub(/OR$/, '')}") unless params[:query].empty?  
  end
  
  def status_collector(searched_field, searched_field_id, parameter, concerned_model)
  	@result = ""
  	@status = concerned_model.where("#{searched_field} ILIKE '%"+parameter+"%'")
  	unless @status.empty? @status.each do |stat|
  		@result << " #{searched_field_id} = #{stat.id}"+" OR"
  		#unless stat.status_name.eql?("administrator") 
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

# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
	default_scope order('users.created_at DESC', 'users.status_id ASC', 'users.status_number ASC', 'users.firstname ASC', 'users.lastname ASC')
	belongs_to :statuses
	#validates :email, :uniqueness => true, :length => { :within => 5..50 }, :format => { :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i }
	validates :firstname, :length => { :in => 2..10 }, :presence => true
	validates :lastname, :length => { :in => 2..20 }, :presence => true
	validates_numericality_of :phone_number, :mobile_number
	validates_length_of :phone_number, :in => 4..8
	validates_length_of :mobile_number, :is => 8
	#validates :subdomain, :exclusion => { :in => %w(www us ca jp), :message => "Subdomain %{value} is reserved." }
  # Include default devise modules. Others available are:
  #:token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :lockable, :timeoutable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :firstname, :lastname, :phone_number, :mobile_number, :status_number, :status_id

	def full_name(current_user)
		@status_name = status(current_user)
		"#{lastname} #{firstname} [#{@status_name}]"
	end
	
	def status(current_user)
		@status_name = Status.find_by_id(current_user.status_id).status_name
		if (@status_name != "Administrateur")
			@status_name << " | #{translate_status(@status_name, current_user)}"
		end
		"#{@status_name}"
  end
	
	def translate_status(status_name, current_user)
  	@status_number = current_user.status_number
  	@chief_of = ''
  	case status_name
  	when "Chef de direction"
  		@chief_of = Direction.find_by_id(@status_number).direction_name
  	when "Chef d'atelier"
  		@chief_of = Workshop.find_by_id(@status_number).workshop_name
  	when "Chef d'équipe"
  		@chief_of = Team.find_by_id(@status_number).team_name
  	end
  	@chief_of
  end
  
  
  def account_enabled?(current_user)
  	if current_user.confirmation_token.eql?(nil)
  		true
  	else
  		false
  	end
  end
end

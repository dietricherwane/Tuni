# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
	belongs_to :statuses
	#validates :email, :uniqueness => true, :length => { :within => 5..50 }, :format => { :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i }
	validates :firstname, :length => { :in => 2..10 }, :presence => true
	validates :lastname, :length => { :in => 2..20 }, :presence => true
	#validates :subdomain, :exclusion => { :in => %w(www us ca jp), :message => "Subdomain %{value} is reserved." }
  # Include default devise modules. Others available are:
  #:token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me, :firstname, :lastname, :phone_number, :mobile_number, :status, :status_id

	def full_name
	"#{lastname.split.first.to_s} #{firstname}"
	end
end

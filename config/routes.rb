# -*- encoding : utf-8 -*-
Tuni::Application.routes.draw do
  get "teams/number_of_casuals"

  get "workshops/number_of_casuals"

	#match 'users/get_workshop' => 'devise/registrations#get_workshop'
	
	devise_for :users, :controllers => {:registrations => "devise/registrations", :sessions => "devise/sessions", :passwords => "devise/passwords"}
	root :to => "fake#index"
	devise_scope :user do
		match 'users/search_ajax' => 'devise/users#search_ajax'
		match 'users/search' => 'devise/users#search'
		match 'users/dae' => 'devise/users#dae', :as => :dae
		match 'users/create_dae' => 'devise/users#create_dae', :as => :create_dae
		match 'users/sign_up' => 'devise/registrations#new', :as => :dashboard
		#root :to => "devise/registrations#new"
		match '/users/sign_in' => 'devise/sessions#new', :as => :sign_in
		match '/users/sign_out' => 'devise/sessions#destroy'
		match 'users/sign_up' => 'devise/registrations#new', :as => :dashboard
		match 'users/sign_up' => 'devise/registrations#new', :as => :dashboard_administrator
    match 'users/get_directions' => 'devise/registrations#get_directions'
    match 'users/get_workshops' => 'devise/registrations#get_workshops'
    match 'users/get_sections' => 'devise/registrations#get_sections'
    match 'users/get_teams' => 'devise/registrations#get_teams'
    match '/users/enable_user' => 'devise/users#enable_user', :as => :enable_user
    match '/users/disable_user' => 'devise/users#disable_user', :as => :disable_user
    match '/users/delete_user' => 'devise/users#delete_user', :as => :delete_user   
    match 'user/edit' => 'devise/users#edit', :as => :edit_user
  	match 'user/update' => 'devise/users#update', :as => :update_user
  	match 'user/change_to_daily_or_normal' => 'devise/users#change_to_daily_or_normal', :as => :change_to_daily_or_normal
  end
  
  match 'casuals/settings' => 'casuals#casuals_settings', :as => :casuals_settings
  match 'create/company' => 'companies#create', :as => :create_company
  match 'create/city' => 'cities#create', :as => :create_city
  match 'cities/new' => 'cities#new', :as => :new_city
  match 'create/casual_type' => 'casual_types#create', :as => :create_casual_type
  match 'casuals/new' => 'casuals#new', :as => :new_casual
  match 'create/casual' => 'casuals#create', :as => :create_casual
  match 'casual/get_workshops' => 'casuals#get_workshops'
  match 'casuals/search' => 'casuals#search_ajax'
  match 'casual/allot_to_team' => 'workshops#allot_to_team', :as => :allot_casual_to_team
  match 'allocation' => 'workshops#casual_allocation', :as => :casual_allocation
  match 'workshop/parameters' => 'workshops#parameters', :as => :workshop_parameters
  match 'workshop/set_parameters' => 'workshops#set_parameters', :as => :set_workshop_parameters
  match 'workshop/next_week_configuration' => 'workshops#next_week_configuration_plan', :as => :next_week_configuration_plan
  match 'workshop/current_week_configuration' => 'workshops#current_week_configuration_plan', :as => :current_week_configuration_plan
  match 'workshop/save_next_week_configuration' => 'workshops#save_next_week_configuration_plan', :as => :save_next_week_configuration_plan
  match 'workshop/save_current_week_configuration' => 'workshops#save_current_week_configuration_plan', :as => :save_current_week_configuration_plan
  match 'workshop/delete_configuration_plan' => 'workshops#delete_configuration_plan', :as => :delete_configuration_plan
  match 'workshop/delete_line' => 'workshops#delete_line', :as => :delete_line
  match 'workshop/delete_working_day' => 'workshops#delete_working_day', :as => :delete_working_day
  match 'workshop/daily_team' => 'workshops#daily_team'
  match 'team/allot_to_line' => 'teams#allot_to_line', :as => :allot_to_line
  match 'team/casual_allocation_to_line' => 'teams#casual_allocation_to_line', :as => :casual_allocation_to_line
  
  #resources :companies
  #resources :cities
  #resources :casual_types
  #resources :casuals

  #devise_for :users

  #get "fake/index"
  
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

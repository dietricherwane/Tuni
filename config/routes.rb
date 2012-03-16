# -*- encoding : utf-8 -*-
Tuni::Application.routes.draw do
	#match 'users/get_workshop' => 'devise/registrations#get_workshop'
	
	devise_for :users, :controllers => {:registrations => "devise/registrations", :sessions => "devise/sessions", :passwords => "devise/passwords"}
	root :to => "fake#index"
	devise_scope :user do
		match 'users/search_ajax' => 'devise/users#search_ajax'
		match 'users/sign_up' => 'devise/registrations#new', :as => :dashboard
		#root :to => "devise/registrations#new"
		match '/users/sign_in' => 'devise/sessions#new'
		match 'users/sign_out' => 'devise/sessions#destroy'
		match 'users/sign_up' => 'devise/registrations#new', :as => :dashboard
		match 'users/sign_up' => 'devise/registrations#new', :as => :dashboard_administrator
    match 'users/get_directions' => 'devise/registrations#get_directions'
    match 'users/get_workshops' => 'devise/registrations#get_workshops'
    match 'users/get_teams' => 'devise/registrations#get_teams'
    match '/users/enable_user' => 'devise/users#enable_user', :as => :enable_user
    match '/users/disable_user' => 'devise/users#disable_user', :as => :disable_user
    match '/users/delete_user' => 'devise/users#delete_user', :as => :delete_user
  end
  

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

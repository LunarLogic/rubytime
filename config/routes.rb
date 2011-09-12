Rubytime::Application.routes.draw do

  devise_for :users
  
  match("/users/:user_id/calendar", :controller => "activities", :action => "calendar")
  match("/projects/:project_id/calendar", :controller => "activities", :action => "calendar")

  match("/free_days/:access_key(.:format)", :method => 'get', :controller => "free_days", :action => "index", :as => :free_days_index)

  match("/invoices/issued", :controller => "invoices", :action => "index", :filter => "issued", :as => :issued_invoices)
  match("/invoices/pending", :controller => "invoices", :action => "index", :filter => "pending", :as => :pending_invoices)

  match('/signin', :controller => 'exceptions', :action => 'unauthenticated', :as => :signin)

  resources :users,
    :member => {
      "settings" => :get
    },
    :collection => {
      "with_roles" => :get,
      "request_password" => :get,
      "reset_password" => :get,
      "authenticate" => :get,
      "with_activities" => :get
    } do
    resource :calendar
    resources :activities
  end
  
  resources :sessions
  resources :currencies
  resources :activities, :collection => { "day" => :get }
  resources :clients
  resources :projects,
    :collection => { "for_clients" => :get },
    :member => { "set_default_activity_type" => :put } do
    resource :calendar
    resources :activities
  end
  resources :roles
  resources :free_days, :collection => { "delete" => :delete }
  resources :hourly_rates
  resources :invoices, :member => { "issue" => :put }
  resource :settings, :controller => 'settings' # TODO conflict with line 30, # .name(:settings)
  
  resources :activity_types, :collection => { "available" => :get, "for_projects" => :get }
  resources :activity_custom_properties

  root(:controller => "home", :action => "index")

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

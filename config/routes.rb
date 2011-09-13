Rubytime::Application.routes.draw do

  devise_for :users
  
  match("/users/:user_id/calendar", :controller => "activities", :action => "calendar")
  match("/projects/:project_id/calendar", :controller => "activities", :action => "calendar")

  match("/free_days/:access_key(.:format)", :method => 'get', :controller => "free_days", :action => "index", :as => :free_days_index)

  match("/invoices/issued", :controller => "invoices", :action => "index", :filter => "issued", :as => :issued_invoices)
  match("/invoices/pending", :controller => "invoices", :action => "index", :filter => "pending", :as => :pending_invoices)

  match('/signin', :controller => 'exceptions', :action => 'unauthenticated', :as => :signin)

  resources :users do
    member do
      get "settings"
    end
    collection do
      get "with_roles"
      get "request_password"
      get "reset_password"
      get "authenticate"
      get "with_activities"
    end
    resource :calendar
    resources :activities
  end
  
  resources :sessions
  resources :currencies
  resources :activities do
    collection { get "day" }
  end
  resources :clients
  resources :projects do
    collection { get "for_clients" }
    member { put "set_default_activity_type" }
    resource :calendar
    resources :activities
  end
  resources :roles
  resources :free_days do
    collection { delete "delete" }
  end
  resources :hourly_rates
  resources :invoices do
    member { put "issue" }
  end
  resource :settings, :controller => 'settings' # TODO conflict with line 30, # .name(:settings)
  
  resources :activity_types do
    collection do
      get "available"
      get "for_projects"
    end
  end
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

Rubytime::Application.routes.draw do

  devise_for :users

  match("/users/:user_id/calendar", :controller => "activities", :action => "calendar")
  match("/projects/:project_id/calendar", :controller => "activities", :action => "calendar")

  match("/invoices/issued", :controller => "invoices", :action => "index", :filter => "issued", :as => :issued_invoices)
  match("/invoices/pending", :controller => "invoices", :action => "index", :filter => "pending", :as => :pending_invoices)

  def users_resources
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

  resources :users do
    users_resources
  end
  resources :employees, :controller => "users" do
    users_resources
  end
  resources :client_users, :controller => "users" do
    users_resources
  end
  
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
  match("/free_days/:access_key(.:format)", :method => 'get', :controller => "free_days", :action => "index", :as => :free_days_index)

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
end

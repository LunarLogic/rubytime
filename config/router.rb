# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")

Merb::Router.prepare do
  match("/password_reset").to(:controller => "users", :action => "password_reset").name(:password_reset)
  match("/users/:user_id/calendar").to(:controller => "activities", :action => "calendar")
  match("/projects/:project_id/calendar").to(:controller => "activities", :action => "calendar")
  match("/activities/day").to(:controller => "activities", :action => "day").name(:activities_for_day)
  match("/free_days/:access_key(.:format)").to(:controller => "free_days", :action => "index").name(:free_days_index)

  match("/users/:id/settings").to(:controller => "users", :action => "settings").name(:user_settings)
  match("/users/request_password").to(:controller => "users", :action => "request_password").name(:request_password)
  match("/users/reset_password").to(:controller => "users", :action => "reset_password").name(:reset_password)

  match("/invoices/issued").to(:controller => "invoices", :action => "index", :filter => "issued").name(:issued_invoices)
  match("/invoices/pending").to(:controller => "invoices", :action => "index", :filter => "pending").name(:pending_invoices)
  
  resources :users, :collection => { "with_roles" => :get, "request_password" => :get,
      "reset_password" => :get, "authenticate" => :get } do
    resource :calendar
    resources :activities
  end
  
  resources :sessions
  resources :currencies
  resources :activities
  resources :clients
  resources :projects, :collection => { "for_clients" => :get } do
    resource :calendar
  end
  resources :roles
  resources :hourly_rates
  resources :invoices, :member => { "issue" => :put }
  resource :settings, :controller => 'settings' # TODO conflict with line 30, # .name(:settings)
  
  # Adds the required routes for merb-auth using the password slice 
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  default_routes
  
  match('/').to(:controller => 'activities', :action =>'index').name(:root)
end
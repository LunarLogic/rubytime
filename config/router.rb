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

  match("/users/:user_id/calendar").
    to(:controller => "activities", :action => "calendar")
  match("/projects/:project_id/calendar").
    to(:controller => "activities", :action => "calendar")

  match("/free_days/:access_key(.:format)", :method => 'get').
    to(:controller => "free_days", :action => "index").name(:free_days_index)

  match("/invoices/issued").
    to(:controller => "invoices", :action => "index", :filter => "issued").name(:issued_invoices)
  match("/invoices/pending").
    to(:controller => "invoices", :action => "index", :filter => "pending").name(:pending_invoices)

  match('/signin').
    to(:controller => 'exceptions', :action => 'unauthenticated').name(:signin)

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
  resources :estimates
  resources :activities, :collection => { "day" => :get }
  resources :clients
  resources :projects, :collection => { "for_clients" => :get } do
    resource :calendar
    resources :activities
    resources :estimates, :collection => { "update_all" => :put }
  end
  resources :roles
  resources :free_days, :collection => { "delete" => :delete }
  resources :hourly_rates
  resources :invoices, :member => { "issue" => :put }
  resource :settings, :controller => 'settings' # TODO conflict with line 30, # .name(:settings)
  
  resources :activity_types, :collection => { "available" => :get, "for_projects" => :get }
  resources :activity_custom_properties
  
  # Adds the required routes for merb-auth using the password slice 
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  default_routes
  
  match('/').to(:controller => 'activities', :action =>'index').name(:root)
end

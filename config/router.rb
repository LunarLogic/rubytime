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
  match("/activities/day").to(:controller => "activities", :action => "day").name(:activities_for_day)

  match("/invoices/issued").to(:controller => "invoices", :action => "index", :filter => "issued").name(:issued_invoices)
  match("/invoices/pending").to(:controller => "invoices", :action => "index", :filter => "pending").name(:pending_invoices)
  
  resources :users, :collection => { "with_roles" => :get } do
    resource :calendar
  end
  
  resources :sessions
  resources :activities
  resources :clients
  resources :projects, :collection => { "for_clients" => :get }
  resources :roles
  resources :invoices
  
  # Adds the required routes for merb-auth using the password slice 
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  default_routes
  
  match('/').to(:controller => 'activities', :action =>'index').name(:root)
end
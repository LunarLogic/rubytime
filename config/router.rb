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
  match("/login").to(:controller => "sessions", :action => "new").name(:login)
  match("/logout").to(:controller => "sessions", :action => "destroy").name(:logout)
  match("/password_reset").to(:controller => "users", :action => "password_reset").name(:password_reset)
  match("/users/:user_id/calendar").to(:controller => "activities", :action => "calendar")
  match("/activities/day").to(:controller => "activities", :action => "day").name(:activities_for_day)
  
  resources :users, :collection => { "with_roles" => :get } do
    resource :calendar
  end
  
  resources :sessions
  resources :activities
  resources :clients
  resources :projects, :collection => { "for_clients" => :get }
  resources :roles
  resources :invoices

  default_routes
  
  match('/').to(:controller => 'sessions', :action =>'index').name(:root)
end
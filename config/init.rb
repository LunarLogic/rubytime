require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :erb
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '1205346b9baa87cf8e49f78124c8d17a31ac0971'  # required for cookie session store
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  Merb::Mailer.delivery_method = :sendmail
  require Merb.root / "lib/rubytime/sha1_hash"
  require Merb.root / "lib/rubytime/authenticated_system"
  require Merb.root / "lib/rubytime/config"
end

Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  require Merb.root / "lib/rubytime/misc"
  require Merb.root / "config/local_config.rb"
  Application.send(:include, Utype::AuthenticatedSystem)
end

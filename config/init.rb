<<<<<<< HEAD:config/init.rb
$KCODE = 'UTF8'

Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

dependencies %w(dm-validations dm-timestamps dm-aggregates merb_has_flash merb-assets merb_helpers dm-sweatshop dm-types)
dependency Merb.root / "lib/rubytime/sha1_hash"

Merb::BootLoader.after_app_loads do
  dependency Merb.root / "lib/rubytime/misc"
  dependency Merb.root / "lib/rubytime/authenticated_system"
  dependency Merb.root / "lib/rubytime/config"
  Application.send(:include, Utype::AuthenticatedSystem)
end

=======
# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
>>>>>>> a8ad00dcc70e559f94f7364860bb51616a1c5cd2:config/init.rb
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
  require Merb.root / "lib/rubytime/sha1_hash"
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  require Merb.root / "lib/rubytime/misc"
  require Merb.root / "lib/rubytime/authenticated_system"

  Application.send(:include, Utype::AuthenticatedSystem)
end

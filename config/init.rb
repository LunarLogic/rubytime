$KCODE = 'UTF8'

Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

dependencies %w(dm-validations dm-timestamps dm-aggregates merb_has_flash merb-assets merb_helpers dm-sweatshop dm-types)

Merb::BootLoader.after_app_loads do
  # For example, the magic_admin gem uses the app's model classes. This requires that the models be 
  # loaded already. So, we can put the magic_admin dependency here:
  # dependency "magic_admin"
  # Application.send(:include, Utype::AuthenticatedSystem)
end

use_orm :datamapper

use_test :rspec

use_template_engine :erb

Merb::Config.use do |c|

  # c[:session_id_key] = '_session_id'
  
  # The session_secret_key is only required for the cookie session store.
  c[:session_secret_key]  = '148455faeb0b36fde2eb28cecc889cd2c3172e76'
  
  # There are various options here, by default Merb comes with 'cookie', 
  # 'memory', 'memcache' or 'container'.  
  # You can of course use your favorite ORM instead: 
  # 'datamapper', 'sequel' or 'activerecord'.
  c[:session_store] = 'cookie'
end

require Merb.root / "gems" / "environment"

require 'digest/sha1'
require "csv" # dependency raises error
 
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
  Merb.add_mime_type(:csv, :to_csv, %w[text/csv])
  Merb::Mailer.delivery_method = :sendmail
  require Merb.root / "lib/rubytime/misc"
end

Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  Rubytime::DATE_FORMATS.each do |name, options|
    Date.add_format(name, options[:format])
  end
  require Merb.root / "config/local_config.rb"
  require 'chronic'
end

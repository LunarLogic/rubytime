Bundler.require :default, ENV['RACK_ENV'] || ENV['MERB_ENV'] || :development

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
  Merb.add_mime_type(:ics, :to_ics, %w[text/calendar])
  Merb::Mailer.delivery_method = :sendmail
  require Merb.root / "lib/rubytime/misc"

  Merb::Plugins.config[:exceptions] = {
    :email_addresses => ['jakub.suder@llp.pl'],
    :app_name        => "RubyTime",
    :environments    => ['production', 'staging'],
    :email_from      => "exceptions@rt.llp.pl",
    :mailer_config => nil,
    :mailer_delivery_method => :sendmail
  }
end

Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  Rubytime::DATE_FORMATS.each do |name, options|
    Date.add_format(name, options[:format])
  end

  Rubytime::Misc.check_activity_roles

  require Merb.root / "config/local_config.rb"
  Dir[ Merb.root / "lib/extensions/*.rb" ].each { |filename| require filename }
end

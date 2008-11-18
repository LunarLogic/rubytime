require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "merb-mailer"
require "dm-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

def Merb.root 
  File.dirname(__FILE__) / ".."
end

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

DataMapper.auto_migrate!

require Merb.root / "spec/rubytime_specs_helper"
require Merb.root / "spec/model_extensions"
require Merb.root / "spec/rubytime_controller_helper"
require Merb.root / "spec/rubytime_fixtures"

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Rubytime::Test::ControllerHelper)
  config.include(Rubytime::Test::SpecsHelper)
  config.include(Rubytime::Test::Fixtures::FixturesHelper)
  
  config.after(:each) do
    repository(:default) do
      while repository.adapter.current_transaction
        repository.adapter.current_transaction.rollback
        repository.adapter.pop_transaction
      end
    end
  end
 
  config.before(:each) do
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
  end
  
  config.before(:all) do
    Activity.all.destroy!
    Invoice.all.destroy!
    User.all.destroy!
    Project.all.destroy!
    Client.all.destroy!
    Role.all.destroy!
    Rubytime::Test::Fixtures::prepare
  end
end

Merb::Mailer.delivery_method = :test_send

require Merb.root / "spec/spec_fixtures"
require Merb.root / "spec/mail_controller_specs_helper"

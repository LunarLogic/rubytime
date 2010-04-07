require 'rubygems'

require 'dm-core'
require 'merb-core'
require 'merb-mailer'
require 'spec'

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
Merb::Mailer.delivery_method = :test_send

require Merb.root / 'spec/factory_patch'
require Merb.root / 'spec/rubytime_factories' # note: not named 'factories' to disable auto-loading
require Merb.root / 'spec/matchers'
require Merb.root / 'spec/rubytime_specs_helper'
require Merb.root / 'spec/controller_helper'
require Merb.root / 'spec/mailer_helper'
require Merb.root / 'spec/model_helper'

DataMapper.auto_migrate!
DataMapper::Model.append_extensions(Rubytime::Test::ModelHelper)

Spec::Runner.configure do |config|
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Rubytime::Test::ControllerHelper)
  config.include(Rubytime::Test::SpecsHelper)
  config.include(Rubytime::Test::MailerHelper)
  config.include(Delorean)

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
end

require "rubygems"

require "merb-core"
require "merb-mailer"
require "dm-core"
require 'factory_girl/syntax/sweatshop'
require "spec"

module RubyTime
  module Test
    module Model
      def gen(*args)
        name = (args.first.is_a?(Symbol) ? args.shift : self.name.snake_case).to_sym
        properties = args.first || {}

        Factory.create(name, properties)
      end
    end
  end
end

DataMapper::Model.append_extensions(RubyTime::Test::Model)

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
Merb::Mailer.delivery_method = :test_send

require Merb.root / 'spec/rubytime_factories'
require Merb.root / "spec/rubytime_fixtures"
require Merb.root / "spec/rubytime_specs_helper"
require Merb.root / "spec/rubytime_controller_helper"
require Merb.root / "spec/model_extensions"
require Merb.root / "spec/mail_controller_specs_helper"

Rubytime::Test::Fixtures::prepare

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
end

require "rubygems"

require 'dm-core'
require "merb-core"
require "merb-mailer"
require "spec"

module Rubytime
  module Test
    module Model
      def parse_factory_arguments(args)
        factory_name = (args.first.is_a?(Symbol) ? args.shift : self.name.snake_case).to_sym
        properties = args.first || {}
        [factory_name, properties]
      end

      def first_or_generate(attributes = {})
        first(attributes) || generate(attributes)
      end

      def generate(*args)
        Factory.create(*parse_factory_arguments(args))
      end

      def prepare(*args)
        Factory.build(*parse_factory_arguments(args))
      end

      def pick
        records = count
        (records > 0) ? first(:limit => 1, :offset => rand(records)) : nil
      end

      def pick_or_generate
        pick || generate
      end

      def prepare_hash(*args)
        Factory.attributes_for(*parse_factory_arguments(args))
      end
    end
  end
end

DataMapper::Model.append_extensions(Rubytime::Test::Model)

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
Merb::Mailer.delivery_method = :test_send

require Merb.root / 'spec/factory_patch'
require Merb.root / 'spec/rubytime_factories'
require Merb.root / "spec/matchers"
require Merb.root / "spec/rubytime_specs_helper"
require Merb.root / "spec/rubytime_controller_helper"
require Merb.root / "spec/model_extensions"
require Merb.root / "spec/mail_controller_specs_helper"

DataMapper.auto_migrate!

Spec::Runner.configure do |config|
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Rubytime::Test::ControllerHelper)
  config.include(Rubytime::Test::SpecsHelper)
  config.include(MailControllerTestHelper)
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

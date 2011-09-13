ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/mocks/standalone'
require 'rspec/autorun'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
require "rubytime_factories"

DataMapper.auto_migrate!
DataMapper::Model.append_extensions(Rubytime::Test::ModelHelper)

RSpec::Runner.configure do |config|
  config.include(Rubytime::Test::ControllerHelper)
  config.include(Rubytime::Test::SpecsHelper)
  config.include(Rubytime::Test::MailerHelper)
  config.include(Devise::TestHelpers, :type => :controller)
  config.include(Delorean)

  config.mock_with :rspec

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

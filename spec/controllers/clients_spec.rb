require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Clients, "index action" do
  include ControllerSpecsHelper

  it "shouldn't allow Employee or Client to create new client" do
    Employee.gen if Employee.count == 0 
    Client.gen   if Client.count == 0
    
    %w(client employee).each do |user_type|
      # dispatch_to_as(Clients, :new, user_type).should be_successful
      # dispatch_to_as(Clients, :create, user_type, :client => { :name => "Kiszonka Inc."}).should be_successful
      # dispatch_to_as_client(Clients, :new).should be_successful
      # dispatch_to_as_client(Clients, :index).should be_successful
      # dispatch_to_as_client(Clients, :create, :client => { :name => "Kiszonka Inc."}).should be_successful
      # dispatch_to_as_employee(Clients, :new).should be_successful
      # dispatch_to_as_employee(Clients, :create, :client => { :name => "Kiszonka Inc."}).should be_successful
      # dispatch_to_as_employee(Clients, :index).should be_successful
    end
  end
end
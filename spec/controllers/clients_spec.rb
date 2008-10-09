require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Clients, "index action" do
  include ControllerSpecsHelper

  before(:all) { prepare_users }

  it "shouldn't allow Employee or Client to create a client and shouldn't display index" do
    %w(client employee).each do |user_type|
      proc do  
        send("dispatch_to_as_#{user_type}".to_sym, Clients, :new) 
      end.should raise_forbidden
      
      proc do
         send("dispatch_to_as_#{user_type}".to_sym, Clients, :index) 
      end.should raise_forbidden
      
      proc do
        send("dispatch_to_as_#{user_type}".to_sym, Clients, :create, :client => { :name => "Kiszonka Inc."}) 
      end.should raise_forbidden
    end
    
    dispatch_to_as_admin(Clients, :new).should be_successful
    dispatch_to_as_admin(Clients, :create, :client => { :name => "Kiszonka Inc."}).should be_successful
    dispatch_to_as_admin(Clients, :index).should be_successful
  end


end
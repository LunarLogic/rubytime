require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Clients, "index action" do
  include ControllerSpecsHelper

  before(:each) { prepare_users }
  
  before(:all) { @client = Client.gen }
  
  it "shouldn't allow Employee or Client to create a client, display index or render edit" do
    %w(client employee).each do |user_type|
      method_name = "dispatch_to_as_#{user_type}".to_sym
      
      proc { send(method_name, Clients, :new) }.should raise_forbidden
      
      proc { send(method_name, Clients, :index) }.should raise_forbidden
      
      proc { send(method_name, Clients, :edit, :id => @client.id) }.should raise_forbidden
      
      proc { send(method_name, Clients, :create, :client => { :name => "Kiszonka Inc."}) }.should raise_forbidden
    end
  end
  
  it("should render new for admin") { dispatch_to_as_admin(Clients, :new).should be_successful }
  
  it("should render edit for admin") { dispatch_to_as_admin(Clients, :edit, :id => @client.id).should be_successful }

  it("should render new for admin") { dispatch_to_as_admin(Clients, :index).should be_successful }
    
  it "should allow admin to create new client and create client user for this client" do
    proc do
      proc do
        dispatch_to_as_admin(Clients, :create, 
          :client => Client.gen_attrs,
          :client_user => ClientUser.gen_attrs(:without_client)
        ).should redirect_to(url(:clients))
      end.should change(Client, :count)
    end.should change(ClientUser, :count)
  end
  
  it "should render new with errors and not save objects when client is invalid" do
    proc do
      proc do
        dispatch_to_as_admin(Clients, :create,
          :client => { :name => "", :email => "" },
          :client_user => ClientUser.gen_attrs(:without_client)
        ).should be_successful
      end.should_not change(Client, :count)
    end.should_not change(ClientUser, :count)
  end
  
  it "should render new with errors and not save objects when ClientUser is invalid" do
    proc do
      proc do
        dispatch_to_as_admin(Clients, :create,
          :client => Client.gen_attrs, 
          :client_user => { :name => "John" }
        ).should be_successful
      end.should_not change(Client, :count)
    end.should_not change(ClientUser, :count)
  end
end
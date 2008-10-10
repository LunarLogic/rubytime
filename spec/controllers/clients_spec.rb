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
    dispatch_to_as_admin(Clients, :index).should be_successful
    proc do
      proc do
        email = "kiszonka@company.com"
        name  = "kiszonka"
        password = "passw0rd"
        
        dispatch_to_as_admin(Clients, :create, 
          :client => { :name => name, :email => email },
          :client_user => { 
            :login => name,
            :email => email,
            :password => password, 
            :password_confirmation => password
          }
        ).should be_successful
      end #.should change(Client, :count)
    end #.should change(ClientUser, :count)

  end
end
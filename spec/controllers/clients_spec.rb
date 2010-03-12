require 'spec_helper'

describe Clients do

  before :each do
    @client = Client.generate
  end

  it "shouldn't allow Employee or Client to create a client, do update, display index or render edit" do
    %w(client employee).each do |user_type|
      method_name = "dispatch_to_as_#{user_type}".to_sym
      
      block_should(raise_forbidden) { send(method_name, Clients, :index) }
      
      block_should(raise_forbidden) { send(method_name, Clients, :edit, :id => fx(:banana).id) }
      
      block_should(raise_forbidden) { send(method_name, Clients, :create, :client => { :name => "Kiszonka Inc."}) }
      
      block_should(raise_forbidden) do
         send(method_name, Clients, :update, :client => { :name => "stefan hX0r" }, :id => fx(:orange).id )
      end
    end
  end

  it "should render edit for admin" do
    as(:admin).dispatch_to(Clients, :edit, :id => @client.id).should be_successful
  end

  it "should render show for admin" do
    as(:admin).dispatch_to(Clients, :show, :id => @client.id).should be_successful
  end

  it "should render index for admin" do
    as(:admin).dispatch_to(Clients, :index).should be_successful
  end

  describe "#create" do
    it "should allow admin to create new client and create client user for this client" do
      block_should(change(Client, :count)).and(change(ClientUser, :count)) do
        response = as(:admin).dispatch_to(Clients, :create,
          :client => Client.prepare_hash,
          :client_user => ClientUser.prepare_hash
        )
        client = response.instance_variable_get(:@client)
        response.should redirect_to(resource(client))
      end
    end

    it "should render new with errors and not save objects when client is invalid" do
      block_should_not(change(Client, :count)).and_not(change(ClientUser, :count)) do
        as(:admin).dispatch_to(Clients, :create,
          :client => { :name => "", :email => "" },
          :client_user => ClientUser.prepare_hash
        ).should be_successful
      end
    end

    it "should render new with errors and not save objects when ClientUser is invalid" do
      block_should_not(change(ClientUser, :count)).and_not(change(Client, :count)) do
        as(:admin).dispatch_to(Clients, :create,
          :client => Client.prepare_hash,
          :client_user => { :name => "John" }
        ).should be_successful
      end
    end
  end

  it "should update client and redirect to show" do
    apple = fx(:apple)
    as(:admin).dispatch_to(Clients, :update, :id => apple.id,
                                    :client => { :name => "new name"}).should redirect_to(resource(apple))
    apple.reload.name.should == "new name"
  end
  
  describe "#destroy" do
    it "should destroy client and client's users" do
      client = fx(:peach)
      block_should(change(ClientUser, :count).by(-client.client_users.count)).and(change(Client, :count).by(-1)) do
        as(:admin).dispatch_to(Clients, :destroy, :id => client.id).status.should == 200
      end
      Client.get(client.id).should be_nil
    end
    
    it "Shouldn't destroy client and client's users if he has any invoices" do
      block_should_not(change(Client, :count)).and_not(change(ClientUser, :count)) do
        as(:admin).dispatch_to(Clients, :destroy, :id => fx(:orange).id).status.should == 400
      end
    end
  end
end
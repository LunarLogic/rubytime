require 'spec_helper'

describe Clients do

  before :each do
    @client = Client.generate
  end

  it "shouldn't allow Employee or Client to create a client, do update, display index or render edit" do
    client = Client.generate

    def should_fail(user, *params)
      block_should(raise_forbidden) { as(user).dispatch_to(*params) }
    end

    [:client, :employee].each do |user|
      should_fail(user, Clients, :index)
      should_fail(user, Clients, :edit, :id => client.id)
      should_fail(user, Clients, :create, :client => { :name => "Kiszonka" })
      should_fail(user, Clients, :update, :client => { :name => "stefan hX0r" }, :id => client.id)
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

  describe "#update" do
    it "should update client and redirect to show" do
      response = as(:admin).dispatch_to(Clients, :update, :id => @client.id, :client => { :name => "new name"})
      response.should redirect_to(resource(@client))
      @client.reload.name.should == "new name"
    end
    
    it "should render edit with errors and not save objects when client is invalid" do
      block_should_not(change(Client, :count)).and_not(change(ClientUser, :count)) do
        as(:admin).dispatch_to(Clients, :update,
          :id => @client.id,
          :client => { :name => "", :email => "" }
        ).should be_successful
      end
    end
  end

  describe "#destroy" do
    it "should destroy client and client's users" do
      client = Client.generate
      users = (0..2).map { ClientUser.generate :client => client }
      block_should(change(ClientUser, :count).by(-3)).and(change(Client, :count).by(-1)) do
        as(:admin).dispatch_to(Clients, :destroy, :id => client.id).status.should == 200
      end
      Client.get(client.id).should be_nil
      users.each { |u| ClientUser.get(u.id).should be_nil }
    end

    it "shouldn't destroy client and client's users if he has any invoices" do
      client = Client.generate
      ClientUser.generate :client => client
      Invoice.generate :client => client
      block_should_not(change(Client, :count)).and_not(change(ClientUser, :count)) do
        as(:admin).dispatch_to(Clients, :destroy, :id => client.id).status.should == 400
      end
    end
  end
end

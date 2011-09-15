require 'spec_helper'

describe ClientsController do

  before :each do
    @client = Client.generate
  end

  it "shouldn't allow Employee or Client to create a client, do update, display index or render edit" do
    client = Client.generate

    [:client, :employee].each do |user|
      login(user)
      get(:index).                                                           status.should == 403
      get(:edit, :id => client.id).                                          status.should == 403
      post(:create, :client => { :name => "Kiszonka" }).                     status.should == 403
      put(:update, :client => { :name => "stefan hX0r" }, :id => client.id). status.should == 403
    end
  end

  context "as admin" do
    login(:admin)
    
    it "should render edit for admin" do
      get(:edit, :id => @client.id).should be_successful
    end

    it "should render show for admin" do
      get(:show, :id => @client.id).should be_successful
    end

    it "should render index for admin" do
      get(:index).should be_successful
    end

    describe "POST 'create'" do
      it "should create new client and create client user for this client" do
        block_should(change(Client, :count)).and(change(ClientUser, :count)) do
          post(:create, :client => Client.prepare_hash,
               :client_user => ClientUser.prepare_hash)
          response.should redirect_to(client_path(assigns[:client]))
        end
      end

      it "should render new with errors and not save objects when client is invalid" do
        block_should_not(change(Client, :count)).and_not(change(ClientUser, :count)) do
          post(:create, :client => { :name => "", :email => "" },
               :client_user => ClientUser.prepare_hash).should be_successful
        end
      end

      it "should render new with errors and not save objects when ClientUser is invalid" do
        block_should_not(change(ClientUser, :count)).and_not(change(Client, :count)) do
          post(:create, :client => Client.prepare_hash,
               :client_user => { :name => "John" }).should be_successful
        end
      end
    end

    describe "PUT 'update'" do
      it "should update client and redirect to show" do
        put(:update, :id => @client.id, :client => { :name => "new name"})
        response.should redirect_to(client_path(@client))
        @client.reload.name.should == "new name"
      end
      
      it "should render edit with errors and not save objects when client is invalid" do
        put(:update, :id => @client.id,
            :client => { :name => "", :email => "" })
        response.should be_successful
        @client.reload.name.should_not be_empty
      end
    end

    describe "DELETE 'destroy'" do
      it "should destroy client and client's users" do
        users = (0..2).map { ClientUser.generate :client => @client }
        block_should(change(ClientUser, :count).by(-3)).and(change(Client, :count).by(-1)) do
          delete(:destroy, :id => @client.id).should be_successful
        end
        Client.get(@client.id).should be_nil
        users.each { |u| ClientUser.get(u.id).should be_nil }
      end

      it "shouldn't destroy client and client's users if he has any invoices" do
        ClientUser.generate :client => @client
        Invoice.generate :client => @client
        block_should_not(change(Client, :count)).and_not(change(ClientUser, :count)) do
          delete(:destroy, :id => @client.id).status.should == 400
        end
      end
    end
  end
end

require 'spec_helper'

describe InvoicesController do
  describe "POST 'create'" do
    before :each do
      @client = Client.generate
      login(:admin)
    end

    it "should create empty invoice" do
      block_should_not(change(Activity.not_invoiced, :count)) do
        post(:create, :invoice => { 
          :name => Factory.attributes_for(:invoice)[:name],
          :client_id => @client.id,
        }).status.should == 302
      end
    end

    it "should create invoice with activities" do
      project = Project.generate :client => @client
      activity = Activity.generate :project => project
      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        post(:create, :invoice => { 
          :name => Factory.attributes_for(:invoice)[:name],
          :client_id => @client.id,
          :activity_id => [activity.id]
        }).status.should == 302
      end
    end

    it "should not create invoice if some of activities are not valid" do
      project = Project.generate :client => @client
      activity = Activity.generate :project => project
      project.activity_types << ActivityType.generate
      project.save

      block_should_not(change(Activity.not_invoiced, :count).by(-1)) do
        post(:create, :invoice => {
          :name => Factory.attributes_for(:invoice)[:name],
          :client_id => @client.id,
          :activity_id => [activity.id]
        }).status.should == 200
      end
    end
  end

  describe "DELETE 'destroy'" do
    login(:admin)

    it "should allow admin to destroy invoice if it's not issued" do
      issued = Invoice.generate
      not_issued = Invoice.generate
      issued.issue!

      block_should(change(Invoice, :count).by(-1)) do
        delete(:destroy, :id => not_issued.id).should be_successful
      end
      block_should_not(change(Invoice, :count)) do
        delete(:destroy, :id => issued.id).status.should == 400
      end
    end
  end

  describe "PUT 'issue'" do
    login(:admin)

    it "should allow admin to issue an invoice" do
      invoice = Invoice.generate
      put(:issue, :id => invoice.id).should redirect_to(invoices_path(invoice))
      invoice.reload.should be_issued
    end
  end

  describe "PUT 'update'" do
    login(:admin)

    it "should allow admin to add activities to existing invoice" do
      client = Client.generate
      project = Project.generate :client => client
      activity = Activity.generate :project => project
      invoice = Invoice.generate :client => client

      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        put(:update, {
          :id => invoice.id,
          :invoice => { :activity_id => [activity.id] }
        }).should redirect_to(invoices_path(invoice))
      end
    end
  end

  describe "GET 'index'" do
    context "as admin" do
      login(:admin)

      it "should allow render a list of invoices" do
        get(:index).should be_successful
        get(:index, :filter => "pending").should be_successful
        get(:index, :filter => "issued").should be_successful
      end
    end

    context "as client" do
      it "should allow client to view list of its invoices" do
        client = Client.generate
        invoices = (0..1).map { Invoice.generate :client => client }
        invoices.first.issue!
        user = ClientUser.generate :client => client
        login(user)
        
        client2 = Client.generate
        invoices2 = (0..1).map { Invoice.generate :client => client2 }
        invoices2.first.issue!
        
        check_response = lambda do |*params|
          get(*params)
          response.should be_successful
          invoices = assigns[:invoices]
          invoices.should_not be_empty
          invoices.reject { |i| i.client == client }.should be_empty
        end

        check_response.call(:index)
        check_response.call(:index, :filter => 'pending')
        check_response.call(:index, :filter => 'issued')
      end
    end
  end

  describe "GET 'show'" do

    before :each do
      @client = Client.generate
      @user = ClientUser.generate :client => @client
      @invoice = Invoice.generate :client => @client
    end

    context "as client" do
      before(:each) do
        login(@user)
      end

      it "should allow clients to view their invoices" do
        get(:show, :id => @invoice.id)
        response.should be_successful
      end

      it "should not allow client to view other client's invoice" do
        get(:show, :id => Invoice.generate.id).status.should == 403
      end
    end

    context "as admin" do
      login(:admin)

      it "should allow admin to view any invoice" do
        get(:show, :id => @invoice.id)
        response.should be_successful
      end
    end
  end
end

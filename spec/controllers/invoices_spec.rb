require 'spec_helper'

describe Invoices do
  describe "#create" do
    before :each do
      @client = Client.generate
    end

    it "should create empty invoice" do
      block_should_not(change(Activity.not_invoiced, :count)) do
        as(:admin).dispatch_to(Invoices, :create, :invoice => { 
          :name => "Theee Invoice",
          :client_id => @client.id,
        }).status.should == 302
      end
    end

    it "should create invoice with activities" do
      project = Project.generate :client => @client
      activity = Activity.generate :project => project
      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        as(:admin).dispatch_to(Invoices, :create, :invoice => { 
          :name => "Theee Invoice",
          :client_id => @client.id,
          :activity_id => [activity.id]
        }).status.should == 302
      end
    end
  end

  describe "#destroy" do
    it "should allow admin to destroy invoice if it's not issued" do
      issued = Invoice.generate
      not_issued = Invoice.generate
      issued.issue!

      block_should(change(Invoice, :count).by(-1)) do
        as(:admin).dispatch_to(Invoices, :destroy, :id => not_issued.id).should be_successful
      end
      block_should_not(change(Invoice, :count)) do
        as(:admin).dispatch_to(Invoices, :destroy, :id => issued.id).status.should == 400
      end
    end
  end

  describe "#issue" do
    it "should allow admin to issue an invoice" do
      invoice = Invoice.generate
      as(:admin).dispatch_to(Invoices, :issue, :id => invoice.id).should redirect
      invoice.reload.should be_issued
    end
  end

  describe "#update" do
    it "should allow admin to add activities to existing invoice" do
      client = Client.generate
      project = Project.generate :client => client
      activity = Activity.generate :project => project
      invoice = Invoice.generate :client => client

      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        as(:admin).dispatch_to(Invoices, :update, {
          :id => invoice.id,
          :invoice => { :activity_id => [activity.id] }
        }).should redirect(resource(invoice))
      end
    end
  end

  describe "#index" do
    it "should allow admin to view list of invoices" do
      as(:admin).dispatch_to(Invoices, :index).should be_successful
      as(:admin).dispatch_to(Invoices, :index, :filter => "pending").should be_successful
      as(:admin).dispatch_to(Invoices, :index, :filter => "issued").should be_successful
    end

    it "should allow client to view list of its invoices" do
      client = Client.generate
      invoices = (0..1).map { Invoice.generate :client => client }
      invoices.first.issue!
      user = ClientUser.generate :client => client

      client2 = Client.generate
      invoices2 = (0..1).map { Invoice.generate :client => client2 }
      invoices2.first.issue!

      check_response = lambda do |*params|
        response = as(user).dispatch_to(*params)
        response.should be_successful
        invoices = response.instance_variable_get(:@invoices)
        invoices.should_not be_empty
        invoices.reject { |i| i.client == client }.should be_empty
      end

      check_response.call(Invoices, :index)
      check_response.call(Invoices, :index, :filter => 'pending')
      check_response.call(Invoices, :index, :filter => 'issued')
    end
  end

  describe "#show" do

    before :each do
      @client = Client.generate
      @user = ClientUser.generate :client => @client
      @invoice = Invoice.generate :client => @client
    end

    it "should allow client to view its invoice" do
      response = as(@user).dispatch_to(Invoices, :show, :id => @invoice.id)
      response.should be_successful
    end

    it "should allow admin to view any invoice" do
      response = as(:admin).dispatch_to(Invoices, :show, :id => @invoice.id)
      response.should be_successful
    end

    it "should not allow client to view other client's invoice" do
      block_should(raise_forbidden) do 
        as(:client).dispatch_to(Invoices, :show, :id => @invoice.id)
      end
    end
  end

end

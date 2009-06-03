require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Invoices do
  describe "#create" do
    it "should create empty invoice" do
      block_should_not(change(Activity.not_invoiced, :count)) do
        as(:admin).dispatch_to(Invoices, :create, :invoice => { 
          :name => "Theee Invoice",
          :client_id => fx(:orange).id,
        }).status.should == 302
      end
    end
    
    it "should create invoice with activities" do
      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        as(:admin).dispatch_to(Invoices, :create, :invoice => { 
          :name => "Theee Invoice",
          :client_id => fx(:orange).id,
          :activity_id => [fx(:jolas_activity1).id]
        }).status.should == 302
      end
    end
  end
  
  describe "#destroy" do
    it "should allow admin to destroy invoice if it's not issued" do
      block_should(change(Invoice, :count).by(-1)) do
        as(:admin).dispatch_to(Invoices, :destroy, :id => fx(:oranges_first_invoice).id).should be_successful
      end
      block_should_not(change(Invoice, :count)) do
        as(:admin).dispatch_to(Invoices, :destroy, :id => fx(:oranges_issued_invoice).id).status.should == 400
      end
    end
  end

  describe "#issue" do
    it "should allow admin to issue an invoice" do
      as(:admin).dispatch_to(Invoices, :issue, :id => fx(:oranges_first_invoice).id).should redirect
    end
  end
  
  describe "#update" do
    it "should allow admin to add activities to existing invoice" do
      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        as(:admin).dispatch_to(Invoices, :update, :id => fx(:oranges_first_invoice).id,
          :invoice => {
            :activity_id => [fx(:jolas_activity1).id]
          }).should redirect(resource(fx(:oranges_first_invoice)))
      end
    end
  end
  
  describe "#index" do
    it "should allow admin to view list of invoices" do
      as(:admin).dispatch_to(Invoices, :index).should be_successful
      as(:admin).dispatch_to(Invoices, :index, :filter => "pending").should be_successful
      as(:admin).dispatch_to(Invoices, :index, :filter => "issued").should  be_successful
    end
  
    it "should allow client to view list of its invoices" do
      clients_user = fx(:orange_user1)
      response = as(clients_user).dispatch_to(Invoices, :index)
      response.should be_successful
      invoices = response.instance_variable_get(:@invoices)
      invoices.should_not be_empty
      invoices.reject { |i| i.client == clients_user.client }.should be_empty
      response = as(clients_user).dispatch_to(Invoices, :index, :filter => "pending")
      response.should be_successful
      invoices = response.instance_variable_get(:@invoices)
      invoices.should_not be_empty
      invoices.reject { |i| i.client == clients_user.client }.should be_empty
      response = as(clients_user).dispatch_to(Invoices, :index, :filter => "issued")
      response.should be_successful
      invoices = response.instance_variable_get(:@invoices)
      invoices.should_not be_empty
      invoices.reject { |i| i.client == clients_user.client }.should be_empty
    end
  end
  
  describe "#show" do
    it "should allow client to view its invoice" do
      clients_user = fx(:orange_user1)
      response = as(clients_user).dispatch_to(Invoices, :show, :id => fx(:oranges_issued_invoice).id)
      response.should be_successful
    end
    
    it "should allow admin to view any invoice" do
      response = as(:admin).dispatch_to(Invoices, :show, :id => fx(:oranges_issued_invoice).id)
      response.should be_successful
    end
    
    it "should not allow client to view other client's invoice" do
      clients_user = fx(:apple_user1)
      block_should(raise_forbidden) do 
        as(clients_user).dispatch_to(Invoices, :show, :id => fx(:oranges_issued_invoice).id)
      end
    end
  end
end
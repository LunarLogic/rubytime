require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Invoices, "index action" do
  before(:each) do
    dispatch_to(Invoices, :index)
  end
  
  it "should somtehing" do
    block_should_not(change(Activity, :not_invoiced)) do
      as(:admin).dispatch_to(Invoices, :create, :invoice => { 
        :name => "Theee Invoice",
        :client_id => fx(:orange).id,
      }).status.should == 200
      #admin.reload # needed to reload admin.activities
      #user.reload # nedded to reload user.activities
    end
  end
end
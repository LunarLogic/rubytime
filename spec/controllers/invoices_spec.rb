require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Invoices, "index action" do
  it "should somtehing" do
    block_should_not(change(Activity, :not_invoiced)) do
      as(:admin).dispatch_to(Invoices, :create, :invoice => { 
        :name => "Theee Invoice",
        :client_id => fx(:orange).id,
      }).status.should == 302
    end
  end
end
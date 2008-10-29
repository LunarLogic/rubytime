require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Client do
  it "should destroy associated client users" do
    client = fx(:banana)
    block_should(change(ClientUser, :count).by(-client.client_users.count)) do
      client.destroy.should be_true
    end
  end
  
  it "should find active clients" do
    Client.count.should == 5
    Client.active.count.should == 3
  end
  
  it "Shouldn't allow to delete client with invoices" do
    client = fx(:orange)
    client.invoices.should_not be_empty
    block_should_not(change(Client, :count)) do
      client.destroy.should be_nil
    end
  end
end
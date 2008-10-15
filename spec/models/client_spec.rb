require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Client do
  it "should destroy associated client users" do
    client = Client.gen
    5.times { ClientUser.gen(:without_client, :client => client) }
    client_users_count = client.client_users.count
    
    proc do
      client.destroy
    end.should change(ClientUser, :count).by(-client_users_count)
  end
  
  it "should find active clients" do
    3.times { Client.gen }
    2.times { Client.gen(:active => false) }
    Client.count.should == 5
    Client.active.count.should == 3
  end
end
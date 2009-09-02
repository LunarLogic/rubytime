require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Client do
  it "should be deleted with associated users and projects if has no invoices and no activities" do
    #client = Client.gen
    #3.times { ClientUser.gen(:client => client) }
    #2.times { Project.gen(:client => client) }
    
    client = fx(:peach)
    block_should(change(Project, :count).by(-client.projects.count)) do
      block_should(change(ClientUser, :count).by(-client.client_users.count)) do
        client.destroy.should be_true
      end
    end
  end
  
  it "should find active clients" do
    Client.count.should == 6
    Client.active.count.should == 4
  end
  
  it "shouldn't be deleted if has no invoices but has activities" do
    client = fx(:apple)
    client.activities.should_not be_empty
    client.invoices.should be_empty
    block_should_not(change(ClientUser, :count)) do
      block_should_not(change(Activity, :count)) do
        block_should_not(change(Project, :count)) do
          block_should_not(change(Client, :count)) do
            client.destroy.should be_nil
          end
        end
      end
    end
  end
  
  it "shouldn't be deleted if has invoices" do
    client = fx(:orange)
    client.invoices.should_not be_empty
    block_should_not(change(ClientUser, :count)) do
      block_should_not(change(Activity, :count)) do
        block_should_not(change(Project, :count)) do
          block_should_not(change(Client, :count)) do
            client.destroy.should be_nil
          end
        end
      end
    end
  end
  
  it "should have default order by :name" do
    prefix = 'test for order of '
    client_1 = Client.gen(:name => prefix + 'D')
    client_2 = Client.gen(:name => prefix + 'B')
    client_3 = Client.gen(:name => prefix + 'A')
    client_4 = Client.gen(:name => prefix + 'C')

    Client.all(:conditions => ["name LIKE ?", prefix + "%"]).should == [client_3, client_2, client_4, client_1]
  end
end
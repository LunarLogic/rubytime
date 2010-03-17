require 'spec_helper'

describe Client do

  it "should be deleted with associated users and projects if has no invoices and no activities" do
    client = Client.generate
    3.times { ClientUser.generate(:client => client) }
    2.times { Project.generate(:client => client) }

    block_should(change(Project, :count).by(-2)) do
      block_should(change(ClientUser, :count).by(-3)) do
        client.destroy.should be_true
      end
    end
  end

  it "should find active clients" do
    active = Client.generate :active => true
    inactive = Client.generate :active => false
    active_clients = Client.active.all
    active_clients.should include(active)
    active_clients.should_not include(inactive)
  end
  
  it "shouldn't be deleted if has no invoices but has activities" do
    client = Client.generate
    project = Project.generate :client => client
    Activity.generate :project => project

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
    client = Client.generate
    Invoice.generate :client => client

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
    client1 = Client.generate :name => prefix + 'D'
    client2 = Client.generate :name => prefix + 'B'
    client3 = Client.generate :name => prefix + 'A'
    client4 = Client.generate :name => prefix + 'C'

    Client.all(:conditions => ["name LIKE ?", prefix + "%"]).should == [client3, client2, client4, client1]
  end
end

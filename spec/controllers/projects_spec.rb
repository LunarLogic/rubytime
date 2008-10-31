require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Projects do
  it "shouldn't show any action for guest, employee and client's user" do
    [:index, :create, :edit, :update, :destroy].each do |action|
      as(:guest).dispatch_to(Projects, action).should redirect_to(url(:login))
      block_should(raise_forbidden) { as(:employee).dispatch_to(Projects, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Projects, action) }
    end
  end

  describe "#index" do
    it "should show index for admin" do
      as(:admin).dispatch_to(Projects, :index).should be_successful
    end
  end

  describe "#create" do
    it "should create new record successfully and redirect to index" do
      block_should(change(Project, :count)) do
        controller = as(:admin).dispatch_to(Projects, :create, { 
          :project => { 
            :name => "Jola", 
            :description => "Jolanta", 
            :client_id => fx(:apple).id
          }
        })
        controller.should redirect_to(resource(controller.instance_variable_get(:@project)))
      end
    end

    it "should should not create record and show errors when invalid data" do
      controller = dispatch_to_as_admin(Projects, :create, { :project => { :name => "Jola" } })
      controller.should be_successful
      controller.should_not redirect_to(url(:projects))
    end
  end
  
  describe "#edit" do
    it "should show edit project form" do
      project = Project.gen
      Project.should_receive(:get).with(project.id.to_s).and_return(project)
      dispatch_to_as_admin(Projects, :edit, :id => project.id).should be_successful
    end

    it "shouldn't show edit project form nonexistent project" do
      lambda { dispatch_to_as_admin(Projects, :edit, :id => 12345678)}.should raise_not_found
    end
  end
  
  describe "#update" do
    it "should update record successfully and redirect to index" do
      apple = fx(:apple)
      project = fx(:oranges_first_project)

      
      dispatch_to_as_admin(Projects, :update, { 
        :id => project.id, 
        :project => { 
          :name => "Misio", 
          :description => "Misiaczek", 
          :client_id => apple.id
        }
      }).should redirect_to(resource(project))
      project.reload
      project.name.should == "Misio"
      project.description.should == "Misiaczek"
      project.client.should == apple
    end

    it "should not update record and show errors" do
      project = fx(:oranges_first_project)
      as(:admin).dispatch_to(Projects, :update, { :id => project.id , :project => { :name => "" } }).should be_successful
    end
  
    it "shouldn't update nonexistent project" do
      block_should(raise_not_found) { as(:admin).dispatch_to(Projects, :update, :id => 12345678, :project => {} ) }
    end
  end
  
  describe "#destroy" do
    it "shouldn't delete nonexistent project" do
      block_should(raise_not_found) { as(:admin).dispatch_to(Projects, :destroy, :id => 12345678) }
    end
  end

  describe "#for_clients" do
    it "should allow admin to see projects for specific clients" do
      as(:admin).dispatch_to(Projects, :for_clients, :search_criteria => {}).status.should == 200
    end
  
    it "should allow employee to see projects for specific clients" do
      as(:employee).dispatch_to(Projects, :for_clients, :search_criteria => {}).status.should == 200
    end

    it "shouldn't allow client to see projects for specific clients" do
      block_should(raise_forbidden) do
        as(:client).dispatch_to(Projects, :for_clients, :search_criteria => {})
      end
    end
  end
end
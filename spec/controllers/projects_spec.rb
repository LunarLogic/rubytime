require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Projects do
  it "shouldn't show any action for guest, employee and client's user" do
    [:create, :edit, :update, :destroy].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(Projects, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(Projects, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Projects, action) }
    end
    block_should(raise_unauthenticated) { as(:guest).dispatch_to(Projects, :index) }
    block_should(raise_forbidden) { as(:employee).dispatch_to(Projects, :index) }
  end

  describe "#index" do
    it "should show index for admin, client and employee requesting json data" do
      as(:admin).dispatch_to(Projects, :index).should be_successful
      as(:client).dispatch_to(Projects, :index).should be_successful
      as(:employee).dispatch_to(Projects, :index) do |ctl|
        ctl.content_type = :json
      end.should be_successful
    end

    it "shouldn't show index for employee" do
      block_should(raise_forbidden) do
        as(:employee).dispatch_to(Projects, :index)
      end
    end
    
    it "should show index for client's user listing only client's projects" do
      user = fx(:apple_user1)
      response = as(user).dispatch_to(Projects, :index)
      response.should be_successful
      response.instance_variable_get(:@projects).reject { |p| p.client == user.client }.should be_empty
    end

    it "should set has_activities flag for projects with activities, if requested via JSON" do
      project = fx(:apples_first_project)
      user = fx(:koza)
      Project.should_receive(:with_activities_for).with(user).and_return([project])
      response = as(user).dispatch_to(Projects, :index, :format => 'json')
      found_projects = response.instance_variable_get("@projects")
      found_projects.should include(project)
      found_projects.find { |p| p == project }.has_activities.should be_true
      found_projects.find_all { |p| p != project }.each { |p| p.has_activities.should be_false }
    end
  end

  describe "#show" do
    it "should render user information for admin" do
      as(:admin).dispatch_to(Projects, :show, { :id => fx(:apples_first_project).id }).should be_successful
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
      as(:admin).dispatch_to(Projects, :edit, :id => project.id).should be_successful
    end

    it "shouldn't show edit project form nonexistent project" do
      lambda { dispatch_to_as_admin(Projects, :edit, :id => 12345678)}.should raise_not_found
    end
  end
  
  describe "#update" do
    it "should update record successfully and redirect to index" do
      apple = fx(:apple)
      project = fx(:oranges_first_project)
      
      as(:admin).dispatch_to(Projects, :update, { 
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
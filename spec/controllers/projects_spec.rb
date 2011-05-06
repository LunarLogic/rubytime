require 'spec_helper'

describe Projects do
  it "shouldn't show any action for guest, employee and client's user" do
    [:create, :edit, :update, :destroy, :set_default_activity_type].each do |action|
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

    it "should show projects with activity types and subactivity types if include_activity_types flag is set" do
      project = Project.generate
      activity_type = ActivityType.generate
      subactivity_type = ActivityType.generate(:parent => activity_type)
      project.activity_types << activity_type
      project.activity_types << subactivity_type
      project.save

      response = as(:employee).dispatch_to(Projects, :index, :format => 'json', :include_activity_types => true)

      response.should be_successful
      project_hash = JSON.parse(response.body).first
      activity_hash = project_hash["available_activity_types"].first
      activity_hash["id"].should == activity_type.id
      activity_hash["name"].should == activity_type.name
      activity_hash["position"].should == activity_type.position
      subactivity_hash = activity_hash["available_subactivity_types"].first
      subactivity_hash["id"].should == subactivity_type.id
      subactivity_hash["name"].should == subactivity_type.name
      subactivity_hash["position"].should == subactivity_type.position
    end

    it "shouldn't show index for employee" do
      block_should(raise_forbidden) do
        as(:employee).dispatch_to(Projects, :index)
      end
    end

    it "should show index for client's user listing only client's projects" do
      client1 = Client.generate
      user1 = ClientUser.generate :client => client1
      project1 = Project.generate :client => client1

      client2 = Client.generate
      project2 = Project.generate :client => client2

      response = as(user1).dispatch_to(Projects, :index)
      response.should be_successful
      response.instance_variable_get(:@projects).should include(project1)
      response.instance_variable_get(:@projects).should_not include(project2)
    end

    it "should set has_activities flag for projects with activities, if requested via JSON" do
      project = Project.generate
      user = Employee.generate
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
      project = Project.generate
      as(:admin).dispatch_to(Projects, :show, { :id => project.id }).should be_successful
    end
  end

  describe "#create" do
    it "should create new record successfully and redirect to index" do
      block_should(change(Project, :count)) do
        response = as(:admin).dispatch_to(Projects, :create, :project => {
          :name => "Jola",
          :description => "Jolanta",
          :client_id => Client.generate.id
        })
        response.should redirect_to(resource(response.instance_variable_get(:@project)))
      end
    end

    it "should should not create record and show errors when invalid data" do
      response = as(:admin).dispatch_to(Projects, :create, :project => { :name => "Jola" })
      response.should be_successful
      response.should_not redirect_to(url(:projects))
    end
  end

  describe "#edit" do
    it "should show edit project form" do
      project = Project.generate
      Project.should_receive(:get).with(project.id.to_s).and_return(project)
      as(:admin).dispatch_to(Projects, :edit, :id => project.id).should be_successful
    end

    it "shouldn't show edit project form for nonexistent project" do
      block_should(raise_not_found) { as(:admin).dispatch_to(Projects, :edit, :id => 12345678) }
    end
  end

  describe "#update" do
    it "should update record successfully and redirect to index" do
      project = Project.generate
      client = project.client
      as(:admin).dispatch_to(Projects, :update, :id => project.id, :project => {
        :name => "Misio",
        :description => "Misiaczek",
        :client_id => client.id
      }).should redirect_to(resource(project))

      project.reload
      project.name.should == "Misio"
      project.description.should == "Misiaczek"
      project.client_id.should == client.id
    end

    it "should not update record and show errors" do
      project = Project.generate
      response = as(:admin).dispatch_to(Projects, :update, { :id => project.id, :project => { :name => "" } })
      response.should be_successful
    end

    it "shouldn't update nonexistent project" do
      block_should(raise_not_found) { as(:admin).dispatch_to(Projects, :update, :id => 12345678, :project => {}) }
    end
  end

  describe "#set_default_activity_type" do
    let(:type) { ActivityType.generate }
    let(:project) { Project.generate(:activity_types => [type]) }

    context "if project doesn't exist" do
      it "should raise not found" do
        block_should(raise_not_found) do
          as(:admin).dispatch_to(Projects, :set_default_activity_type, :id => 888, :activity_type_id => type.id)
        end
      end
    end

    context "if activity type doesn't exist" do
      it "should raise not found" do
        block_should(raise_not_found) do
          as(:admin).dispatch_to(Projects, :set_default_activity_type, :id => project.id, :activity_type_id => 888)
        end
      end
    end

    context "if both project and activity type exist" do
      let(:type2) { ActivityType.generate }

      before :each do
        project.activity_types = []
        project.save
        project.reload

        @activities_without_types = (0..1).map { Activity.generate(:project => project, :activity_type => nil) }

        project.activity_types = [type, type2]
        project.save
        project.reload

        @activities_with_types = (0..1).map { Activity.generate(:project => project, :activity_type => type2) }

        as(:admin).dispatch_to(Projects, :set_default_activity_type, :id => project.id, :activity_type_id => type.id)
      end

      context "if activities have a type assigned" do
        it "shouldn't update them" do
          @activities_with_types.each do |a|
            a.reload
            a.activity_type.should == type2
          end
        end
      end

      context "if activities don't have a type assigned" do
        it "should set their type" do
          @activities_without_types.each do |a|
            a.reload
            a.activity_type.should == type
          end
        end
      end
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

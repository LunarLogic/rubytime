require 'spec_helper'

describe ProjectsController do

  context "as guest" do
    login(:guest)

    it "should ask to login on any action" do
      get(:index).                               should redirect_to(new_user_session_path)
      post(:create).                             should redirect_to(new_user_session_path)
      get(:edit, :id => 1).                      should redirect_to(new_user_session_path)
      put(:update, :id => 1).                    should redirect_to(new_user_session_path)
      delete(:destroy, :id => 1).                should redirect_to(new_user_session_path)
      put(:set_default_activity_type, :id => 1). should redirect_to(new_user_session_path)
    end
  end

  context "as non-admin user" do
    it "should forbid all actions" do
      [:employee, :client].each do |user|
        login(user)

        post(:create).                             status.should == 403
        get(:edit, :id => 1).                      status.should == 403
        put(:update, :id => 1).                    status.should == 403
        delete(:destroy, :id => 1).                status.should == 403
        put(:set_default_activity_type, :id => 1). status.should == 403        
      end
    end
  end

  describe "GET 'index'" do
    context "as admin" do
      login(:admin)

      it { get(:index).should be_successful }
    end

    context "as client" do
      login(:client)

      it { get(:index).should be_successful }
      
      it "should show index for client's user listing only client's projects" do
        project1 = Project.generate :client => @current_user.client
        project2 = Project.generate

        get(:index)
        response.should be_successful
        assigns[:projects].should include(project1)
        assigns[:projects].should_not include(project2)
      end
    end

    context "as employee" do
      login(:employee)

      it "should show index when requesting json data" do
        get(:index, :format => :json).should be_successful
        response.content_type = :json
      end

      it "should show projects with activity types and subactivity types if include_activity_types flag is set" do
        Project.all.destroy!
        project = Project.generate
        activity_type = ActivityType.generate
        subactivity_type = ActivityType.generate(:parent => activity_type)
        project.activity_types << activity_type
        project.activity_types << subactivity_type
        project.save

        get(:index, :format => 'json', :include_activity_types => true)

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
        get(:index).status.should == 403
      end

      it "should set has_activities flag for projects with activities, if requested via JSON" do
        project = Project.generate
        Project.should_receive(:with_activities_for) do |user|
            user.should == @current_user
            [project]
        end

        get(:index, :format => 'json')
        found_projects = assigns[:projects]
        found_projects.should include(project)
        found_projects.find { |p| p == project }.has_activities.should be_true
        found_projects.find_all { |p| p != project }.each { |p| p.has_activities.should be_false }
      end
    end
  end

  describe "GET 'show'" do
    login(:admin)

    it { get(:show, { :id => Project.generate.id }).should be_successful }
  end

  describe "POST 'create'" do
    login(:admin)
    
    it "should create new record successfully and redirect to the new record" do
      block_should(change(Project, :count)) do
        post(:create, :project => {
          :name => "Jola",
          :description => "Jolanta",
          :client_id => Client.generate.id
        })
        response.should redirect_to(projects_path(assigns[:project], :expand_hourly_rates => "yes"))
      end
    end

    it "should should not create record and show errors when invalid data" do
      post(:create, :project => { :name => "Jola" })
      response.should be_successful
      response.should_not be_redirect
    end
  end

  describe "GET 'edit'" do
    login(:admin)

    it "should show edit project form" do
      project = Project.generate
      Project.should_receive(:get).with(project.id.to_s).and_return(project)
      get(:edit, :id => project.id.to_s).should be_successful
    end

    it "shouldn't show edit project form for nonexistent project" do
      get(:edit, :id => 12345678).status.should == 404
    end
  end

  describe "PUT 'update'" do
    login(:admin)

    it "should update record successfully and redirect to show" do
      project = Project.generate
      client = project.client
      put(:update, :id => project.id, :project => {
        :name => "Misio",
        :description => "Misiaczek",
        :client_id => client.id
      }).should redirect_to(projects_path(project))

      project.reload
      project.name.should == "Misio"
      project.description.should == "Misiaczek"
      project.client_id.should == client.id
    end

    it "should not update record and show errors" do
      project = Project.generate
      put(:update, { :id => project.id, :project => { :name => "" } })
      response.should be_successful
      project.reload.name.should_not == ""
    end

    it "shouldn't update nonexistent projects" do
      put(:update, :id => 12345678, :project => {}).status.should == 404
    end
  end

  describe "PUT 'set_default_activity_type'" do
    let(:type) { ActivityType.generate }
    let(:project) { Project.generate(:activity_types => [type]) }
    login(:admin)

    context "if project doesn't exist" do
      it "should raise not found" do
        put(:set_default_activity_type, :id => 888, :activity_type_id => type.id).status.should == 404
      end
    end

    context "if activity type doesn't exist" do
      it "should raise not found" do
        put(:set_default_activity_type, :id => project.id, :activity_type_id => 888).status.should == 404
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

        put(:set_default_activity_type, :id => project.id, :activity_type_id => type.id)
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

  describe "DELETE 'destroy'" do
    login(:admin)

    it "shouldn't delete nonexistent project" do
      delete(:destroy, :id => 12345678).status.should == 404
    end
  end

  describe "GET 'for_clients'" do
    context "as admin" do     
      login(:admin)

      it { get(:for_clients, :search_criteria => {}).should be_successful }
    end

    context "as employee" do
      login(:employee)      

      it { get(:for_clients, :search_criteria => {}).should be_successful }
    end


    context "as client" do
      login(:client)

      it { get(:for_clients, :search_criteria => {}).status.should == 403 }
    end
  end
end

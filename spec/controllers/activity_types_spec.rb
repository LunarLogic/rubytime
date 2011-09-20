require 'spec_helper'

describe ActivityTypesController do
  context "as guest" do
    login(:guest)
    
    it "should ask to login on any action" do
      get(:index).                               should redirect_to(new_user_session_path)
      post(:create).                             should redirect_to(new_user_session_path)
      get(:show, :id => 1).                      should redirect_to(new_user_session_path)
      get(:edit, :id => 1).                      should redirect_to(new_user_session_path)
      put(:update, :id => 1).                    should redirect_to(new_user_session_path)
      delete(:destroy, :id => 1).                should redirect_to(new_user_session_path)
      get(:available).                           should redirect_to(new_user_session_path)
      get(:for_projects).                        should redirect_to(new_user_session_path)
    end
  end

  context "as non-admin user" do
    it "should forbid some actions" do
      [:employee, :client].each do |user|
        login(user)

        get(:index).                               status.should == 403
        post(:create).                             status.should == 403
        get(:show, :id => 1).                      status.should == 403
        get(:edit, :id => 1).                      status.should == 403
        put(:update, :id => 1).                    status.should == 403
        delete(:destroy, :id => 1).                status.should == 403
      end
    end
  end

  context "as employee" do
    login(:employee)

    describe "GET 'available'" do
      it { get(:available, :project_id => Project.generate.id, :format => :json).should be_successful }
    end

    describe "GET 'for_projects'" do
      it { get(:for_projects).should be_successful }
    end
  end

  context "as client" do
    login(:client)

    describe "GET 'available'" do
      let(:project) { Project.generate(:client => @current_user.client) }
      
      it "should show activities for client's project" do
        get(:available, :project_id => project.id, :format => :json).should be_successful
      end
      
      it "should not show activites for other clients projects" do
        get(:available, :project_id => Project.generate.id, :format => :json).status.should == 403
      end
    end
    
    describe "GET 'for_projects'" do
      it { get(:for_projects).should be_successful }
    end
  end

  context "as admin" do
    login(:admin)

    describe "GET 'index'" do
      pending
    end

    describe "POST 'create'" do
      pending
    end

    describe "GET 'show'" do
      pending
    end

    describe "GET 'edit'" do
      pending
    end

    describe "PUT 'update'" do
      pending
    end

    describe "DELETE 'destroy'" do
      pending
    end

    describe "GET 'available'" do
      pending
    end

    describe "GET 'for_projects'" do
      pending
    end
  end

end

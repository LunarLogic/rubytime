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
      before(:each) do
        @activity_type = ActivityType.generate
        @sub_activity_type = ActivityType.generate(:parent => @activity_type)
        get(:index)
      end

      it { response.should be_successful }

      it "should show a list of root activity types" do
        assigns[:activity_types].should == ActivityType.roots
      end

      it "should prepare a new activity type for the form" do
        assigns[:new_activity_type].should be_new
      end
    end

    describe "POST 'create'" do
      context "when creating a root activity type" do
        let(:attributes) { Factory.attributes_for(:activity_type) }

        it "should redirect to index" do
          post(:create, :activity_type => attributes)
          response.should redirect_to activity_types_path
        end      

        it "should create an activity" do
          block_should(change(ActivityType, :count).by(1)) do
            post(:create, :activity_type => attributes)
          end
        end

        context "when supplying invalid parameters" do
          let(:invalid) { attributes.merge(:name => nil) }
          
          it "should not create an activity" do
            block_should_not(change(ActivityType, :count)) do
              post(:create, :activity_type => invalid)
            end
          end

          it "should show index" do
            post(:create, :activity_type => invalid).should render_template(:index)
          end
        end
      end

      context "when creating a sub-activity type" do
        let(:parent) { ActivityType.generate }
        before(:each) do
          @attributes = Factory.attributes_for(:activity_type).merge(:parent_id => parent.id)
        end

        it "should redirect to parent" do
          post(:create, :activity_type => @attributes)
          response.should redirect_to activity_type_path(parent)
        end

        it "should create an activity" do
          block_should(change(ActivityType, :count).by(1)) do
            post(:create, :activity_type => @attributes)
          end
        end

        context "when supplying invalid parameters" do
          let(:invalid) { @attributes.merge(:name => nil) }
          
          it "should not create an activity" do
            block_should_not(change(ActivityType, :count)) do
              post(:create, :activity_type => invalid)
            end
          end

          it "should show parent" do
            post(:create, :activity_type => invalid).should render_template(:show)
          end
        end
      end
    end

    describe "GET 'show'" do
      let(:activity_type) { ActivityType.generate }

      it { get(:show, :id => "no such id").status.should == 404 }

      it { get(:show, :id => activity_type.id).should be_successful }

      it "should show the activity type" do
        get(:show, :id => activity_type.id).should render_template(:show)
        assigns[:activity_type].should == activity_type        
      end

      it "should prepare a new activity type for the form" do
        get(:show, :id => activity_type.id)
        assigns[:new_activity_type].should be_new
        assigns[:new_activity_type].parent.should == activity_type
      end
    end

    describe "GET 'edit'" do
      let(:activity_type) { ActivityType.generate }
      
      it { get(:edit, :id => "no such id").status.should == 404 }

      it { get(:edit, :id => activity_type.id).should be_successful }

      it { get(:edit, :id => activity_type.id, :format => :json).status.should == 406 }

      it "should show the activity edit form" do
        get(:edit, :id => activity_type.id).should render_template(:edit)
        assigns[:activity_type].should == activity_type
      end
    end

    describe "PUT 'update'" do
      let(:activity_type) { ActivityType.generate }

      it { put(:update, :id => "no such id").status.should == 404 }

      it { put(:update, :id => activity_type.id, :activity_type => {}).should redirect_to(activity_types_path) }

      it "should update the activity type" do
        put(:update, :id => activity_type.id, :activity_type => {:name => "New name"})
        activity_type.reload.name.should == "New name"
      end

      context "updating a sub activity type" do
        let(:sub_activity_type) { ActivityType.generate(:parent_id => activity_type.id) }

        it "should redirect to parent" do
          put(:update, :id => sub_activity_type.id, :activity_type => {})
          response.should redirect_to(activity_type_path(activity_type))
        end
      end

      context "attributes are invalid" do
        let(:invalid) { {:name => nil} }

        it { put(:update, :id => activity_type.id, :activity_type => invalid).should render_template(:edit) }

        it "should not update if attributes are invalid" do
          put(:update, :id => activity_type.id, :activity_type => invalid)
          activity_type.reload.name.should_not be_nil
        end
      end
    end

    describe "DELETE 'destroy'" do
      let(:activity_type) { ActivityType.generate }
      
      it { delete(:destroy, :id => "no such id").status.should == 404 }

      it { delete(:destroy, :id => activity_type.id).should redirect_to(activity_types_path) }

      it "should destroy the activity type" do
        delete(:destroy, :id => activity_type.id)
        ActivityType.get(activity_type.id).should be_nil
      end

      context "when destroying a sub activity type" do
        let(:sub_activity_type) { ActivityType.generate(:parent_id => activity_type.id) }

        it { delete(:destroy, :id => sub_activity_type.id).should redirect_to(activity_type_path(activity_type)) }
      end
    end
  end
end

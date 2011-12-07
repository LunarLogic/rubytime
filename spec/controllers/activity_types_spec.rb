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

        get(:index).                               should be_forbidden
        post(:create).                             should be_forbidden
        get(:show, :id => 1).                      should be_forbidden
        get(:edit, :id => 1).                      should be_forbidden
        put(:update, :id => 1).                    should be_forbidden
        delete(:destroy, :id => 1).                should be_forbidden
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
        get(:available, :project_id => Project.generate.id, :format => :json).should be_forbidden
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
      subject { get(:show, :id => activity_type_id) }

      context "with an incorrect id" do
        let(:activity_type_id) { "no such id" }

        it "should return 404" do
          expect { subject }.to raise_error(DataMapper::ObjectNotFoundError)
        end
      end

      context "with a correct id" do
        let(:activity_type) { ActivityType.generate }
        let(:activity_type_id) { activity_type.id }

        it { should be_successful }
        it { should render_template(:show) }

        it "should show the activity type" do
          subject
          assigns[:activity_type].should == activity_type
        end

        it "should prepare a new activity type for the form" do
          subject
          assigns[:new_activity_type].should be_new
          assigns[:new_activity_type].parent.should == activity_type
        end
      end
    end

    describe "GET 'edit'" do
      subject { get(:edit, :id => activity_type_id) }

      context "with an incorrect id" do
        let(:activity_type_id) { "no such id" }

        it "should return 404" do
          expect { subject }.to raise_error(DataMapper::ObjectNotFoundError)
        end
      end

      context "with a correct id" do
        let(:activity_type) { ActivityType.generate }
        let(:activity_type_id) { activity_type.id }

        it { should be_successful }
        it { should render_template(:edit) }

        it "should show the activity edit form" do
          subject
          assigns[:activity_type].should == activity_type
        end

        context "with an incorrect format" do
          subject { get(:edit, :id => activity_type_id, :format => :json) }

          it { should be_not_acceptable }
        end
      end
    end

    describe "PUT 'update'" do
      subject { put(:update, :id => activity_type_id, :activity_type => { :name => "New name" }) }

      context "with an incorrect id" do
        let(:activity_type_id) { "no such id" }

        it "should return 404" do
          expect { subject }.to raise_error(DataMapper::ObjectNotFoundError)
        end
      end

      context "with a correct id" do
        let(:activity_type) { ActivityType.generate }
        let(:activity_type_id) { activity_type.id }

        it { should redirect_to(activity_types_path) }

        it "should update the activity type" do
          subject
          activity_type.reload.name.should == "New name"
        end

        context "with invalid attributes" do
          subject { put(:update, :id => activity_type.id, :activity_type => { :name => nil }) }

          it { should render_template(:edit) }

          it "should not update" do
            subject
            activity_type.reload.name.should_not be_nil
          end
        end
      end

      context "updating a sub activity type" do
        let(:parent_activity_type) { ActivityType.generate }
        let(:activity_type) { ActivityType.generate(:parent_id => parent_activity_type.id) }
        let(:activity_type_id) { activity_type.id }

        it { should redirect_to(activity_type_path(parent_activity_type)) }
      end
    end

    describe "DELETE 'destroy'" do
      subject { delete(:destroy, :id => activity_type_id) }

      context "with an incorrect id" do
        let(:activity_type_id) { "no such id" }

        it "should return 404" do
          expect { subject }.to raise_error(DataMapper::ObjectNotFoundError)
        end
      end

      context "with a correct id" do
        let(:activity_type) { ActivityType.generate }
        let(:activity_type_id) { activity_type.id }

        it { should redirect_to(activity_types_path) }

        it "should destroy the activity type" do
          subject
          ActivityType.get(activity_type.id).should be_nil
        end

        context "when destroying a sub activity type" do
          let(:sub_activity_type) { ActivityType.generate(:parent_id => activity_type.id) }

          subject { delete(:destroy, :id => sub_activity_type.id) }

          it { should redirect_to(activity_type_path(activity_type)) }
        end
      end
    end
  end
end

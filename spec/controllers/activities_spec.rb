require 'spec_helper'

describe ActivitiesController do
  context "as admin" do
    login(:admin)
    
    it "should export activities to CSV" do
      project = Project.generate
      activities = [
                    Activity.generate(:project => project, :date => Date.today - 1),
                    Activity.generate(:project => project, :date => Date.today - 2)
                   ]

      get(:index, :project_id => project.id, :format => :csv )

      lines = response.body.split(/\n/)
      lines.length.should == 3
      lines[0].should =~ /Client;Project;Role/
      lines[1].index(activities[0].project.name).should_not be_nil
      lines[1].index(activities[0].comments).should_not be_nil
      lines[2].index(activities[1].project.client.name).should_not be_nil
      lines[2].index(activities[1].comments).should_not be_nil
    end
  end

  describe "GET 'index'" do
    context "as employee" do
      login(:employee)

      it { get(:index).should be_successful }

      it "should include activity locked? field in JSON response" do
        project = Project.generate
        Activity.generate :user => @current_user, :project => project

        get(:index, :search_criteria => { :limit => 1 }, :format => 'json')
        response.body.should =~ /"locked\?"/
      end        
      
      it "should filter by project if actions is accessed by /projects/x/activities" do
        project = Project.generate
        get(:index, :project_id => project.id.to_s)
        assigns[:search_criteria].selected_project_ids.should == [project.id.to_s]
      end
    end

    context "as client" do
      login (:client)

      it { get(:index).should be_successful }
    end

    context "as admin" do
      login(:admin)

      it { get(:index).should be_successful }
    end
  end

  describe "GET 'new'" do
    context "as employee" do
      login(:employee)

      it "should show 3 recent and rest of projects when adding new activity" do
        user = @current_user
        projects = (0..4).map { |i| Project.generate :name => "Project#{i}" }

        Activity.generate :user => user, :project => projects[0], :date => Date.parse('2009-07-01')
        Activity.generate :user => user, :project => projects[1], :date => Date.parse('2009-07-03')
        Activity.generate :user => user, :project => projects[2], :date => Date.parse('2009-07-07')
        Activity.generate :user => user, :project => projects[3], :date => Date.parse('2009-07-02')
        Activity.generate :user => user, :project => projects[4], :date => Date.parse('2009-07-04')
        Activity.generate :user => Employee.generate, :project => projects[0], :date => Date.parse('2009-07-11')

        get(:new)
        response.should be_successful
        assigns[:recent_projects].should == [projects[2], projects[4], projects[1]]

        assigns[:other_projects].should include(projects[0])
        assigns[:other_projects].should include(projects[3])
      end

      it "should preselect current user in new activity form when user is not admin" do
        user = @current_user
        other_user = Employee.generate
        
        get(:new)
        response.should be_successful
        assigns[:activity].user.should == user
        
        get(:new, :user_id => other_user.id)
        response.should be_successful
        assigns[:activity].user.should == user
      end
    end

    context "as admin" do
      login(:admin)
      
      it "should preselect given user in new activity form when user is admin" do
        admin = @current_user
        user = Employee.generate

        get(:new)
        response.should be_successful
        assigns[:activity].user.should == admin

        get(:new, :user_id => user.id)
        response.should be_successful
        assigns[:activity].user.should == user
      end
    end
  end
  
  describe "POST 'create'" do

    before :each do
      @user = Employee.generate
      @admin = Employee.generate(:admin)
      @project = Project.generate
      ensure_rate_exists :project => @project, :role => @user.role, :takes_effect_at => Date.today
      ensure_rate_exists :project => @project, :role => @admin.role, :takes_effect_at => Date.today
      @fields = {
        :date => Date.today,
        :hours => "7",
        :project_id => @project.id,
        :comments => "this & that",
      }
    end

    context "as user" do
      before :each do
        login(@user)
      end
      
      it "should add new activity" do
        post(:create, :activity => @fields)
        response.status.should == 200
        Activity.last.user.should == @user
      end

      it "should not add invalid activity" do
        post(:create,:activity => @fields.merge(:comments => ""))
        response.status.should == 400
      end

      it "should raise bad request if adding activity for nonexistent project" do
        post(:create, :activity => @fields.merge(:project_id => 923874293))
        response.status.should == 400
      end
      
      it "should not add activity for other user if current user isn't admin" do
        other = Employee.generate
        
        block_should(change(@user.activities, :count).by(1)).and_not(change(other.activities, :count)) do
          post(:create, :activity => @fields.merge(:user_id => other.id))
          response.status.should == 200
        end
        Activity.last.user.should == @user
      end

      it "should set user field to current user if not set" do
        block_should(change(@user.activities, :count).by(1)) do
          post(:create, :activity => @fields.merge(:project_id => @project.id))
          response.status.should == 200
        end
        Activity.last.user.should == @user
      end

      it "should not set activity's frozen price or invoice" do
        block_should(change(Activity, :count).by(1)) do
          post(:create, :activity => @fields.merge(:price_value => 2.5,
                                                   :price_currency_id => Currency.first_or_generate.id,
                                                   :invoice_id => Invoice.generate(:client => @project.client).id))
          response.should be_successful
        end
        Activity.last.price_currency.should be_nil
        Activity.last.price_value.should be_nil
        Activity.last.invoice.should be_nil
      end

      it "should not crash when :activity hash isn't set" do
        post(:create)
        response.status.should == 400
      end
    end

    context "as admin" do
      before :each do
        login(@admin)
      end

      it "should add activity for other user if current user is admin" do
        block_should(change(@user.activities, :count).by(1)).and_not(change(@admin.activities, :count)) do
          post(:create, :activity => @fields.merge(:project_id => @project.id, :user_id => @user.id))
          response.status.should == 200
        end
        Activity.last.user.should == @user
      end

      it "should set user field to current user if not set, even for admin" do
        block_should(change(@admin.activities, :count).by(1)) do
          post(:create, :activity => @fields.merge(:project_id => @project.id))
          response.status.should == 200
        end
        Activity.last.user.should == @admin
      end
    end

    context "as client user" do
      before :each do
        @client_user = ClientUser.generate(:client => @project.client)
        login(@client_user)
      end

      it "should not add activity for client user" do
        block_should_not(change(Activity, :count)) do
          post(:create, :activity => @fields.merge(:user_id => @client_user.id))
          response.status.should == 403
        end
      end
    end
  end

  describe "GET 'edit'" do
    before :each do
      @activity = Activity.generate
    end

    context "as owner" do
      before :each do
        login(@activity.user)
      end

      it "should be successful" do
        get(:edit, :id => @activity.id).should be_successful
      end
    end

    context "as admin" do
      login(:admin)

      it "should be successful" do
        get(:edit, :id => @activity.id).should be_successful
      end
    end

    context "as another user" do
      login(:employee)
      
      it "shouldn't show edit form" do
        expect { get(:edit, :id => @activity.id) }.to raise_error(DataMapper::ObjectNotFoundError)
      end
    end
  end

  describe "PUT 'update'" do
    before :each do
      @activity = Activity.generate
    end

    context "as owner" do
      before :each do
        login(@activity.user)
      end

      it "should update user's activity" do
        put(:update, :id => @activity.id, :activity => {
              :date => Date.today,
              :project_id => @activity.project.id,
              :hours => "3:03",
              :comments => "updated this stuff"
            }).should be_successful
        @activity.reload.comments.should == "updated this stuff"
      end

      it "should not change activity ownership if current user is not admin" do
        old_user = @activity.user
        put(:update, :id => @activity.id, :activity => {:user_id => Employee.generate.id})
        @activity.reload.user.should == old_user
      end

      it "should not change activity's frozen price or invoice" do
        invoice = Invoice.generate :client => @activity.project.client
        currency = Currency.first_or_generate
        
        put(:update, :id => @activity.id, :activity => {
              :price_value => 2.5,
              :price_currency_id => currency.id,
              :invoice_id => invoice.id
            }).should be_successful

        @activity.reload
        @activity.price_currency.should be_nil
        @activity.price_value.should be_nil
        @activity.invoice.should be_nil

        @activity.update :price_currency_id => currency.id, :price_value => 1.0, :invoice_id => invoice.id

        put(:update, :id => @activity.id, :activity => {
              :price_value => 2.5,
              :price_currency_id => Currency.generate.id,
              :invoice_id => Invoice.generate(:client => @activity.project.client).id
            }).should be_successful
        
        @activity.reload
        @activity.price_currency.should == currency
        @activity.price_value.should == 1.0
        @activity.invoice.should == invoice
      end      
    end

    context "as another user" do
      login(:employee)

      it "shouldn't update other user's activity" do
        expect {
          put(:update, :id => @activity.id, :activity => {:comments => "updated again" })
        }.to raise_error(DataMapper::ObjectNotFoundError)

        @activity.reload.comments.should_not == "updated again"
      end
    end

    context "as admin" do
      login(:admin)

      it "should update other user's activity" do
        put(:update, :id => @activity.id, :activity => {:comments => "and once again"})
        response.should be_successful
        @activity.reload.comments.should == "and once again"
      end
      
      it "should change activity ownership if current user is admin" do
        new_user = Employee.generate(:role_id => @activity.user.role_id)
        put(:update, :id => @activity.id, :activity => {:user_id => new_user.id})
        @activity.reload.user.should == new_user
      end
    end

    it "should not crash when :activity hash isn't set" do
      block_should_not(raise_error) { get(:update, :id => @activity.id) }
    end

    it "should always edit correct activity's custom properties" do
      # see commit 00844245983d7ec013e1b04f4e54e8f16af4dfd2 for explanation
      employee = Employee.generate
      project = Project.generate
      property = ActivityCustomProperty.generate
      login(employee)
      activity1, activity2 = (0..1).map { Activity.generate :project => project, :user => employee }

      activity1.update :custom_properties => { property.id => 5 }
      activity2.update :custom_properties => { property.id => 7 }

      get(:update, :id => activity1.id, :activity => {
        :custom_properties => { property.id => 20 }
      })
      response.should be_successful

      Activity.get(activity1.id).custom_properties[property.id].should == 20
      Activity.get(activity2.id).custom_properties[property.id].should == 7

      get(:update, :id => activity2.id, :activity => {
        :custom_properties => { property.id => 45 }
      })
      response.should be_successful

      Activity.get(activity1.id).custom_properties[property.id].should == 20
      Activity.get(activity2.id).custom_properties[property.id].should == 45
    end
  end

  describe "DELETE 'destroy'" do
    before :each do
      @activity = Activity.generate
    end

    context "as admin" do
      login(:admin)
      
      it "should allow admin to delete activity" do
        block_should(change(Activity, :count).by(-1)) do
          delete(:destroy, { :id => @activity.id }).should be_successful
        end    
      end

      it "should raise not found for deleting activity with nonexistent id" do
        expect { delete(:destroy, { :id => 290384923 }) }.to raise_error(DataMapper::ObjectNotFoundError)
      end
    end

    context "as owner" do
      before :each do
        login(@activity.user)
      end

      it "should allow owner to delete activity" do
        block_should(change(Activity, :count).by(-1)) do
          delete(:destroy, { :id => @activity.id }).should be_successful
        end
      end
    end

    context "as another user" do
      login(:employee)

      it "shouldn't allow user to delete other's activities" do
        block_should_not(change(Activity, :count)) do
          expect { delete(:destroy, { :id => @activity.id }) }.to raise_error(DataMapper::ObjectNotFoundError)
        end
      end
    end
  end

  describe "GET 'calendar'" do
    context "as employee" do
      before(:each) do
        @employee = Employee.generate
        login(@employee)
      end

      context "should render calendar for" do
        before(:each) do
          @activities = mock('Activities')
          Employee.any_instance.should_receive(:activities).and_return(@activities)
        end

        it "current month if no date given in the request" do
          @activities.should_receive(:for).with(:this_month).and_return([])
          get(:calendar, { :user_id => @employee.id }).should be_successful
        end
      
        it "given month" do
          year, month = 2007, 10
          @activities.should_receive(:for).with(:year => year, :month => month).and_return([])
          get(:calendar, {:user_id => @employee.id,
                :month => month,
                :year => year
              }).should be_successful
        end
      end

      it "should work as xhr" do
        xhr(:get, :calendar, :user_id => @employee.id).should be_successful
      end

      it "should render bad request error for wrong date" do
        get(:calendar, { :user_id => @employee.id, :year => 3300, :month => 10 })
        response.status.should == 400
      end

      it "should be successful for user requesting his calendar" do
        get(:calendar, :user_id => @employee.id).should be_successful
      end

      it "should raise forbidden for trying to view other's calendars" do
        get(:calendar, :user_id => Employee.generate.id).status.should == 403
      end
    end

    context "as admin" do
      login(:admin)

      it "should be successful for admin requesting user's calendar" do
        get(:calendar, :user_id => Employee.generate.id).should be_successful
      end
    end

    context "as client" do
      before(:each) do
        @project = Project.generate
        @client = ClientUser.generate(:client => @project.client)
        login(@client)        
      end
      
      it "should be successful for client requesting his project's calendar" do
        get(:calendar, :project_id => @project.id).should be_successful
      end

      it "should raise forbidden for trying to view other client's project's calendar" do
        get(:calendar, :project_id => Project.generate.id).status.should == 403
      end
    end
  end

  describe "GET 'day'" do
    context "as employee" do
      login(:employee)

      it "should raise Forbidden when user's trying to view other user calendar" do
        get(:day, :search_criteria => { :user_id => [Employee.generate.id] }).status.should == 403
      end
    end

    context "as client" do
      before(:each) do
        @project = Project.generate
        @client = ClientUser.generate(:client => @project.client)
        login(@client) 
      end

      it "should show day on calendar for client's project" do
        get(:day, {:search_criteria => {
                :project_id => [@project.id],
                :date_from => '2000-01-01'}})
        response.should be_successful
      end

      it "should raise Forbidden when client is trying to view other client's calendar" do
        get(:day, { :search_criteria => { :project_id => [Project.generate.id] }})
        response.status.should == 403
      end
    end
  end
end

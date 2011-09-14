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

  describe "#new" do
    it "should show 3 recent and rest of projects when adding new activity" do
      user = Employee.generate
      projects = (0..4).map { |i| Project.generate :name => "Project#{i}" }

      Activity.generate :user => user, :project => projects[0], :date => Date.parse('2009-07-01')
      Activity.generate :user => user, :project => projects[1], :date => Date.parse('2009-07-03')
      Activity.generate :user => user, :project => projects[2], :date => Date.parse('2009-07-07')
      Activity.generate :user => user, :project => projects[3], :date => Date.parse('2009-07-02')
      Activity.generate :user => user, :project => projects[4], :date => Date.parse('2009-07-04')
      Activity.generate :user => Employee.generate, :project => projects[0], :date => Date.parse('2009-07-11')

      response = as(user).dispatch_to(Activities, :new)
      response.should be_successful
      recent_projects = response.instance_variable_get(:@recent_projects)
      recent_projects.should == [projects[2], projects[4], projects[1]]

      other_projects = response.instance_variable_get(:@other_projects)
      other_projects.should include(projects[0])
      other_projects.should include(projects[3])
    end

    it "should preselect given user in new activity form when user is admin" do
      admin = Employee.generate(:admin)
      user = Employee.generate

      controller = as(admin).dispatch_to(Activities, :new)
      controller.should be_successful
      controller.instance_variable_get(:@activity).user.should == admin

      controller = as(admin).dispatch_to(Activities, :new, :user_id => user.id)
      controller.should be_successful
      controller.instance_variable_get(:@activity).user.should == user
    end

    it "should preselect current user in new activity form when user is not admin" do
      user = Employee.generate
      other_user = Employee.generate

      controller = as(user).dispatch_to(Activities, :new)
      controller.should be_successful
      controller.instance_variable_get(:@activity).user.should == user

      controller = as(user).dispatch_to(Activities, :new, :user_id => other_user.id)
      controller.should be_successful
      controller.instance_variable_get(:@activity).user.should == user
    end
  end

  describe "#create" do

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

    it "should add new activity" do
      as(@user).dispatch_to(Activities, :create, :activity => @fields).status.should == 200
      Activity.last.user.should == @user
    end

    it "should not add invalid activity" do
      as(@user).dispatch_to(Activities, :create, :activity => @fields.merge(
        :comments => ""
      )).status.should == 400
    end

    it "should raise bad request if adding activity for nonexistent project" do
      block_should(raise_bad_request) do
        as(@user).dispatch_to(Activities, :create, :activity => @fields.merge(:project_id => 923874293))
      end
    end

    it "should not add activity for other user if current user isn't admin" do
      other = Employee.generate

      block_should(change(@user.activities, :count).by(1)).and_not(change(other.activities, :count)) do
        as(@user).dispatch_to(Activities, :create, :activity => @fields.merge(
          :user_id => other.id
        )).status.should == 200
      end
      Activity.last.user.should == @user
    end

    it "should add activity for other user if current user is admin" do
      block_should(change(@user.activities, :count).by(1)).and_not(change(@admin.activities, :count)) do
        as(@admin).dispatch_to(Activities, :create, :activity => @fields.merge(
          :project_id => @project.id,
          :user_id => @user.id
        )).status.should == 200
      end
      Activity.last.user.should == @user
    end

    it "should set user field to current user if not set" do
      block_should(change(@user.activities, :count).by(1)) do
        response = as(@user).dispatch_to(Activities, :create, :activity => @fields.merge(:project_id => @project.id))
        response.status.should == 200
      end
      Activity.last.user.should == @user
    end

    it "should set user field to current user if not set, even for admin" do
      block_should(change(@admin.activities, :count).by(1)) do
        response = as(@admin).dispatch_to(Activities, :create, :activity => @fields.merge(:project_id => @project.id))
        response.status.should == 200
      end
      Activity.last.user.should == @admin
    end

    it "should not add activity for client user" do
      client_user = ClientUser.generate :client => @project.client

      block_should(raise_forbidden).and_not(change(Activity, :count)) do
        as(client_user).dispatch_to(Activities, :create, :activity => @fields.merge(:user_id => client_user.id))
      end
    end

    it "should not set activity's frozen price or invoice" do
      block_should(change(Activity, :count).by(1)) do
        as(@user).dispatch_to(Activities, :create, :activity => @fields.merge(
          :price_value => 2.5,
          :price_currency_id => Currency.first_or_generate.id,
          :invoice_id => Invoice.generate(:client => @project.client).id
        )).status.should == 200
      end
      Activity.last.price_currency.should be_nil
      Activity.last.price_value.should be_nil
      Activity.last.invoice.should be_nil
    end

    it "should not crash when :activity hash isn't set" do
      block_should(raise_bad_request) { as(@user).dispatch_to(Activities, :create) }
    end

  end

  describe "#edit" do
    before :each do
      @activity = Activity.generate
    end

    it "should show edit form for activity owner" do
      as(@activity.user).dispatch_to(Activities, :edit, :id => @activity.id).status.should be_successful
    end

    it "should show edit form for admin" do
      as(:admin).dispatch_to(Activities, :edit, :id => @activity.id).status.should be_successful
    end

    it "shouldn't show edit form for other user" do
      block_should(raise_not_found) do
        as(:employee).dispatch_to(Activities, :edit, :id => @activity.id)
      end
    end
  end

  describe "#update" do
    before :each do
      @activity = Activity.generate
    end

    it "should update user's activity" do
      as(@activity.user).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
        :date => Date.today,
        :project_id => @activity.project.id,
        :hours => "3:03",
        :comments => "updated this stuff"
      }).status.should be_successful
    end

    it "shouldn't update other user's activity" do
      block_should(raise_not_found) do
        as(:employee).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
          :comments => "updated again"
        })
      end
    end

    it "should update other user's activity if current user is admin" do
      as(:admin).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
        :comments => "and once again"
      })
    end

    it "should not change activity ownership if current user is not admin" do
      old_user = @activity.user
      as(old_user).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
        :user_id => Employee.generate.id
      })
      @activity.reload.user.should == old_user
    end

    it "should change activity ownership if current user is admin" do
      old_user = @activity.user
      new_user = Employee.generate(:role_id => old_user.role_id)
      as(:admin).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
        :user_id => new_user.id
      })
      @activity.reload.user.should == new_user
    end

    it "should not change activity's frozen price or invoice" do
      invoice = Invoice.generate :client => @activity.project.client
      currency = Currency.first_or_generate

      as(@activity.user).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
        :price_value => 2.5,
        :price_currency_id => currency.id,
        :invoice_id => invoice.id
      }).status.should be_successful

      @activity.reload
      @activity.price_currency.should be_nil
      @activity.price_value.should be_nil
      @activity.invoice.should be_nil

      @activity.update :price_currency_id => currency.id, :price_value => 1.0, :invoice_id => invoice.id

      as(@activity.user).dispatch_to(Activities, :update, :id => @activity.id, :activity => {
        :price_value => 2.5,
        :price_currency_id => Currency.generate.id,
        :invoice_id => Invoice.generate(:client => @activity.project.client).id
      }).status.should be_successful

      @activity.reload
      @activity.price_currency.should == currency
      @activity.price_value.should == 1.0
      @activity.invoice.should == invoice
    end

    it "should not crash when :activity hash isn't set" do
      block_should_not(raise_error) { as(@activity.user).dispatch_to(Activities, :update, :id => @activity.id) }
    end

    it "should always edit correct activity's custom properties" do
      # see commit 00844245983d7ec013e1b04f4e54e8f16af4dfd2 for explanation
      employee = Employee.generate
      project = Project.generate
      property = ActivityCustomProperty.generate
      activity1, activity2 = (0..1).map { Activity.generate :project => project, :user => employee }

      activity1.update :custom_properties => { property.id => 5 }
      activity2.update :custom_properties => { property.id => 7 }

      as(employee).dispatch_to(Activities, :update, :id => activity1.id, :activity => {
        :custom_properties => { property.id => 20 }
      })

      Activity.get(activity1.id).custom_properties[property.id].should == 20
      Activity.get(activity2.id).custom_properties[property.id].should == 7

      as(employee).dispatch_to(Activities, :update, :id => activity2.id, :activity => {
        :custom_properties => { property.id => 45 }
      })

      Activity.get(activity1.id).custom_properties[property.id].should == 20
      Activity.get(activity2.id).custom_properties[property.id].should == 45
    end
  end

  describe "#destroy" do

    before :each do
      @activity = Activity.generate
    end

    it "should allow admin to delete activity" do
      block_should(change(Activity, :count).by(-1)) do
        as(:admin).dispatch_to(Activities, :destroy, { :id => @activity.id }).should be_successful
      end    
    end

    it "should allow owner to delete activity" do
      block_should(change(Activity, :count).by(-1)) do
        as(@activity.user).dispatch_to(Activities, :destroy, { :id => @activity.id }).should be_successful
      end
    end

    it "shouldn't allow user to delete other's activities" do
      block_should(raise_not_found).and_not(change(Activity, :count)) do
        as(:employee).dispatch_to(Activities, :destroy, { :id => @activity.id }).should be_successful
      end
    end

    it "should raise not found for deleting activity with nonexistent id" do
      block_should(raise_not_found) do
        as(:admin).dispatch_to(Activities, :destroy, { :id => 290384923 })
      end
    end
  end

  describe "#calendar" do
    it "should match /users/3/calendar to Activites#calendar with user_id = 3" do
      response = request_to("/users/3/calendar", :get)
      response.should route_to(Activities, :calendar)
      response[:user_id].should == "3"
    end

    it "should match /projects/4/calendar to Activites#calendar with project_id = 4" do
      response = request_to("/projects/4/calendar", :get)
      response.should route_to(Activities, :calendar)
      response[:project_id].should == "4"
    end

    it "should render calendar for current month if no date given in the request" do
      repository(:default) do # identity map doesn't work outside repository block
        employee = Employee.generate
        employee.activities.should_receive(:for).with(:this_month).and_return([])
        as(employee).dispatch_to(Activities, :calendar, { :user_id => employee.id }).should be_successful
      end
    end

    it "should render calendar for given month" do
      repository(:default) do # same as above
        employee = Employee.generate
        year, month = 2007, 10
        employee.activities.should_receive(:for).with(:year => year, :month => month).and_return([])
        response = as(employee).dispatch_to(Activities, :calendar, {
          :user_id => employee.id,
          :month => month,
          :year => year
        })
        response.should be_successful
      end
    end

    it "should render bad request error for wrong date" do
      block_should(raise_bad_request) do
        employee = Employee.generate
        as(employee).dispatch_to(Activities, :calendar, { :user_id => employee.id, :year => 3300, :month => 10 })
      end
    end

    it "should be successful for user requesting his calendar" do
      employee = Employee.generate
      as(employee).dispatch_to(Activities, :calendar, :user_id => employee.id).should be_successful
    end

    it "should raise forbidden for trying to view other's calendars" do
      block_should(raise_forbidden) do
        employee = Employee.generate
        as(:employee).dispatch_to(Activities, :calendar, :user_id => employee.id)
      end
    end

    it "should be successful for admin requesting user's calendar" do
      employee = Employee.generate
      as(:admin).dispatch_to(Activities, :calendar, :user_id => employee.id).should be_successful
    end

    it "should be successful for client requesting his project's calendar" do
      project = Project.generate
      client_user = ClientUser.generate :client => project.client
      as(client_user).dispatch_to(Activities, :calendar, :project_id => project.id).should be_successful
    end

    it "should raise forbidden for trying to view other client's project's calendar" do
      project = Project.generate
      other_client_user = ClientUser.generate
      block_should(raise_forbidden) do
        as(other_client_user).dispatch_to(Activities, :calendar, :project_id => project.id)
      end
    end
  end

  describe "#day" do
    it "should dispatch to Activities#day" do
      request_to("/activities/day").should route_to(Activities, :day)
    end

    it "should raise Forbidden when user's trying to view other user calendar" do
      user = Employee.generate
      block_should(raise_forbidden) do
        as(:employee).dispatch_to(Activities, :day, :search_criteria => { :user_id => [user.id] })
      end
    end

    it "should show day on calendar for client's project" do
      project = Project.generate
      client_user = ClientUser.generate :client => project.client
      response = as(client_user).dispatch_to(Activities, :day, {
        :search_criteria => {
          :project_id => [project.id],
          :date_from => '2000-01-01'
        }
      })
      response.should be_successful
    end

    it "should raise Forbidden when client is trying to view other client's calendar" do
      project = Project.generate
      other_client_user = ClientUser.generate
      block_should(raise_forbidden) do
        as(other_client_user).dispatch_to(Activities, :day, { :search_criteria => { :project_id => [project.id] }})
      end
    end
  end

end

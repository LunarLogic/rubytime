require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Activities do
  
  it "should should match /activities to Activities#index" do
    request_to("/activities", :get).should route_to(Activities, :index)
  end
  
  it "should show 3 recent and rest of projects when adding new activity" do
    jola = fx(:jola) #jola has 3 activities for orange project
    
    controller = as(jola).dispatch_to(Activities, :new)
    controller.should be_successful
    recent_projects = controller.instance_variable_get(:@recent_projects)
    recent_projects.size.should == 3
    
    other_projects = controller.instance_variable_get(:@other_projects)
    other_projects.size.should == Project.active.count - 3
  end
  
  it "should add new activity" do
    as(fx(:misio)).dispatch_to(Activities, :create, :activity => { 
      :date => Date.today,
      :project_id => fx(:bananas_first_project).id,
      :hours => "7",
      :comments => "this & that"
    }).status.should == 201
  end
  
  it "should not add invalid activity" do
    as(:employee).dispatch_to(Activities, :create, :activity => { 
      :date => Date.today,
      :project_id => Project.gen.id,
      :hours => "6:30",
      :comments => ""
    }).status.should == 400
  end
  
  it "should not add activity for other user if he isn't admin" do
    employee = fx(:jola)
    another_emplyee = fx(:misio)

    block_should(change(employee.activities, :count).by(1)).and_not(change(another_emplyee.activities, :count)) do
      as(employee).dispatch_to(Activities, :create, :activity => { 
        :date => Date.today,
        :project_id => fx(:oranges_first_project).id,
        :hours => "7",
        :comments => "this & that",
        :user_id => another_emplyee.id
      }).status.should == 201
      employee.reload # nedded to reload employee.activity 
    end
  end
  
  it "should add activity for other user if he is admin" do
    admin = fx(:admin)
    user = fx(:misio)
    
    block_should(change(user.activities, :count).by(1)).and_not(change(admin.activities, :count)) do
      as(admin).dispatch_to(Activities, :create, :activity => { 
        :date => Date.today,
        :project_id => fx(:oranges_first_project).id,
        :hours => "7",
        :comments => "this & that",
        :user_id => user.id
      }).status.should == 201
      admin.reload # needed to reload admin.activities
      user.reload # nedded to reload user.activities 
    end
  end
  
  it "should render calendar for current month if no date given in the request" do
    repository(:default) do # identity map doesn't work outside repository block
      employee = Employee.gen
      employee.activities.should_receive(:for).with(:this_month).and_return([])
      as(employee).dispatch_to(Activities, :calendar, { :user_id => employee.id }).should be_successful
    end
  end
  
  it "should render calendar for given month" do
    repository(:default) do # same as above
      employee = Employee.first
      year, month = 2007, 10
      employee.activities.should_receive(:for).with(:year => year, :month => month).and_return([])
      controller = as(employee).dispatch_to(Activities, :calendar, { :user_id => employee.id, :month => month, :year => year })
      controller.should be_successful
    end
  end

  it "should render bad request error for wrong date" do
    block_should(raise_bad_request) do
      as(employee = Employee.gen).dispatch_to(
        Activities, :calendar, { :user_id => employee.id, :year => 3300, :month => 10 })
    end
  end
  
  it "should allow admin to delete activity" do
    block_should(change(Activity, :count).by(-1)) do
      delete_jolas_activity_as(:admin).should be_successful
    end    
  end
  
  it "should allow owner to delete activity" do
    block_should(change(Activity, :count).by(-1)) do
      delete_jolas_activity_as(fx(:jola)).should be_successful
    end
  end
  
  it "shouldn't allow user to delete other's activities" do
    block_should(raise_forbidden).and_not(change(Activity, :count)) do
      delete_jolas_activity_as fx(:stefan)
    end
  end
  
  it "should raise not found for deleting activity with nonexistent id" do
    block_should(raise_not_found) do
      as(:admin).dispatch_to(Activities, :destroy, { :id => 123123123 })
    end
  end

  describe "#calendar" do
    it "should match /users/3/calendar to Activites#calendar with user_id = 3" do
      request_to("/users/3/calendar", :get).should route_to(Activities, :calendar)
    end

    it "should be successful for user requesting for his calendar" do
      user = fx(:stefan)
      as(user).dispatch_to(Activities, :calendar, :user_id => user.id).should be_successful
    end

    it "should be successful for admin requesting for user's calendar" do
      as(:admin).dispatch_to(Activities, :calendar, :user_id => fx(:jola).id).should be_successful
    end

    it "should raise forbidden for trying to view other's calendars" do
      block_should(raise_forbidden) do
        as(fx(:misio)).dispatch_to(Activities, :calendar, :user_id => fx(:jola).id)
      end
    end
  end

  describe "#day" do
    it "should dispatch to Activities#day" do
      request_to("/activities/day").should route_to(Activities, :day)
    end

    it "should raise Forbidden when user's trying to view other user calendar" do
      day_with_jolas_activities = fx(:jola).activities.first.created_at
      block_should(raise_forbidden) do
        as(fx(:misio)).dispatch_to(Activities, :day, { :search_criteria => { 
          :user_id => [fx(:jola).id], :date_from => day_with_jolas_activities, :date_to => day_with_jolas_activities 
        }})
      end
    end
    
    it "should raise bad request for day without activities" do
      search_criteria = { :user_id => [fx(:jola).id], :date_from => 30.days.ago, :date_to => 30.days.ago }
      block_should(raise_bad_request) do 
        as(:admin).dispatch_to(Activities, :day, :search_criteria => search_criteria)
      end
    end
  end
  
  protected 
  
  def delete_jolas_activity_as(user)
    as(user).dispatch_to(Activities, :destroy, { :id => fx(:jolas_activity1).id })
  end
end
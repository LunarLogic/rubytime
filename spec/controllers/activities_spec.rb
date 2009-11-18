require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Activities do
  
  it "should should match /activities to Activities#index" do
    request_to("/activities", :get).should route_to(Activities, :index)
  end

  it "should should match /project/x/activities to Activities#index with :project_id set" do
    project_id = fx(:oranges_first_project).id
    request = request_to("/projects/#{project_id}/activities", :get)
    request.should route_to(Activities, :index).with(:project_id => project_id.to_s)
  end
  
  describe "#index" do
    it "should show list of activities" do
      as(:employee).dispatch_to(Activities, :index).should be_successful
      as(:client).dispatch_to(Activities, :index).should be_successful
      as(:admin).dispatch_to(Activities, :index).should be_successful
    end

    it "should include activity locked? field in JSON response" do
      response = as(:employee).dispatch_to(Activities, :index, :format => 'json')
      response.body.should =~ /"locked\?"/
    end

    it "should filter by project if actions is accessed by /projects/x/activities" do
      proj_id = fx(:oranges_first_project).id
      response = as(:employee).dispatch_to(Activities, :index, :project_id => proj_id)
      response.instance_variable_get("@search_criteria").selected_project_ids.should == [proj_id.to_s]
    end
  end

  describe "#new" do
    it "should show 3 recent and rest of projects when adding new activity" do
      jola = fx(:jola) #jola has 3 activities for orange project
      
      controller = as(jola).dispatch_to(Activities, :new)
      controller.should be_successful
      recent_projects = controller.instance_variable_get(:@recent_projects)
      recent_projects.size.should == 3
      
      other_projects = controller.instance_variable_get(:@other_projects)
      other_projects.size.should == Project.active.count - 3
    end
  
    it "should preselect current user in new activity form when user is admin" do
      admin = fx(:admin)
      controller = as(admin).dispatch_to(Activities, :new)
      controller.should be_successful
      controller.instance_variable_get(:@activity).user.should == admin
    end
  end
  
  describe "#create" do
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
        :project_id => fx(:apples_first_project).id,
        :hours => "6:30",
        :comments => ""
      }).status.should == 400
    end

    it "should raise bad request if adding activity for nonexistent project" do
      block_should(raise_bad_request) do
        as(:employee).dispatch_to(Activities, :create, :activity => {
          :date => Date.today,
          :project_id => 1234567,
          :hours => "6:30",
          :comments => "boo"
        })
      end
    end
    
    it "should not add activity for other user if he isn't admin" do
      employee = fx(:jola)
      another_employee = fx(:misio)
  
      block_should(change(employee.activities, :count).by(1)).and_not(change(another_employee.activities, :count)) do
        as(employee).dispatch_to(Activities, :create, :activity => { 
          :date => Date.today,
          :project_id => fx(:oranges_first_project).id,
          :hours => "7",
          :comments => "this & that",
          :user_id => another_employee.id
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

    it "should not crash when :activity hash isn't set" do
      block_should(raise_bad_request) { as(:employee).dispatch_to(Activities, :create) }
    end

  end

  describe "#edit" do
    it "should show edit form for activity owner" do
      as(fx(:jola)).dispatch_to(Activities, :edit, :id => fx(:jolas_activity1).id).status.should be_successful
    end

    it "should show edit form for admin" do
      as(fx(:admin)).dispatch_to(Activities, :edit, :id => fx(:jolas_activity1).id).status.should be_successful
    end

    it "shouldn't show edit form for other user" do
      block_should(raise_not_found) do
        as(fx(:misio)).dispatch_to(Activities, :edit, :id => fx(:jolas_activity1).id)
      end
    end
  end

  describe "#update" do
    it "should update user's activity" do
      as(fx(:jola)).dispatch_to(Activities, :update, :id => fx(:jolas_activity1).id, :activity => {
        :date => Date.today,
        :project_id => fx(:apples_first_project).id,
        :hours => "3:03",
        :comments => "updated this stuff"
      }).status.should be_successful
    end

    it "shouldn't update other user's activity" do
      block_should(raise_not_found) do
        as(fx(:misio)).dispatch_to(Activities, :update, :id => fx(:jolas_activity1).id, :activity => {
          :date => Date.today,
          :project_id => fx(:apples_first_project).id,
          :hours => "3:03",
          :comments => "updated this stuff"
        })
      end
    end

    it "should not crash when :activity hash isn't set" do
      lambda { as(:employee).dispatch_to(Activities, :update, :id => fx(:jolas_activity1).id) }.should_not raise_error
    end

  end

  describe "#destroy" do
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
      block_should(raise_not_found).and_not(change(Activity, :count)) do
        delete_jolas_activity_as fx(:stefan)
      end
    end
    
    it "should raise not found for deleting activity with nonexistent id" do
      block_should(raise_not_found) do
        as(:admin).dispatch_to(Activities, :destroy, { :id => 123123123 })
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
        employee = Employee.gen(:role => fx(:developer))
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
        as(employee = Employee.gen(:role => fx(:developer))).dispatch_to(
          Activities, :calendar, { :user_id => employee.id, :year => 3300, :month => 10 })
      end
    end
    
    it "should be successful for user requesting his calendar" do
      user = fx(:stefan)
      as(user).dispatch_to(Activities, :calendar, :user_id => user.id).should be_successful
    end

    it "should raise forbidden for trying to view other's calendars" do
      block_should(raise_forbidden) do
        as(fx(:misio)).dispatch_to(Activities, :calendar, :user_id => fx(:jola).id)
      end
    end

    it "should be successful for admin requesting user's calendar" do
      as(:admin).dispatch_to(Activities, :calendar, :user_id => fx(:jola).id).should be_successful
    end

    it "should be successful for client requesting his project's calendar" do
      as(fx(:apple_user1)).dispatch_to(Activities, :calendar, :project_id => fx(:apples_first_project).id).should be_successful
    end
    
    it "should raise forbidden for trying to view other client's project's calendar" do
      block_should(raise_forbidden) do
        as(fx(:orange_user1)).dispatch_to(Activities, :calendar, :project_id => fx(:apples_first_project).id)
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
    
    it "should show day on calendar for client's project" do
      project = fx(:apples_first_project)
      as(fx(:apple_user1)).dispatch_to(Activities, :day, { :search_criteria => { 
          :project_id => [project.id], :date_from => project.activities.first.date.to_s
      }}).should be_successful
    end
    
    it "should raise Forbidden when client is trying to view other client's calendar" do
      block_should(raise_forbidden) do
        as(fx(:orange_user1)).dispatch_to(Activities, :day, { :search_criteria => { 
          :project_id => [fx(:apples_first_project).id], :date_from => "2008-11-24"
        }})
      end
    end
  end
  
  protected 
  
  def delete_jolas_activity_as(user)
    as(user).dispatch_to(Activities, :destroy, { :id => fx(:jolas_activity1).id })
  end
end
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Activities, "index action" do
  
  it "should should match /activities to Activity#index" do
    request_to("/activities", :get).should route_to(Activities, :index)
  end
  
  it "should show 3 recent and rest of projects when adding new activity" do
    employee = Employee.gen
    other_employee = Employee.gen
    
    # three projects with activities by this employee
    p1 = Project.gen
    p2 = Project.gen
    p3 = Project.gen
    # p1 is least recent project from all three
    2.times { Activity.make(:user => employee, :project => p1, :created_at => Date.today - 2).save }
    # p2 is most recent project
    2.times { Activity.make(:user => employee, :project => p2, :created_at => Date.today).save }
    # p3 is second most recent project
    2.times { Activity.make(:user => employee, :project => p3, :created_at => Date.today - 1).save }
    
    # 15 projects, each with 1 activity by other employee
    15.times do
      project = Project.gen
      Activity.make(:user => other_employee, :project => project).save
    end
    
    # one inactive project
    Project.gen(:active => false)
    
    controller = dispatch_to_as_employee(Activities, :new)
    controller.should be_successful
    recent_projects = controller.instance_variable_get(:@recent_projects)
    recent_projects.size.should == 3
    recent_projects[0].should == p2
    recent_projects[1].should == p3
    recent_projects[2].should == p1
    
    other_projects = controller.instance_variable_get(:@other_projects)
    other_projects.size.should == Project.active.count - 3
  end
  
  it "should add new activity" do
    Employee.gen
    response = dispatch_to_as_employee(Activities, :create, :activity => { 
      :date => Date.today,
      :project_id => Project.gen.id,
      :hours => "7",
      :comments => "this & that",
    })
    response.status.should == 201
  end
  
  it "should not add invalid activity" do
    Employee.gen
    response = dispatch_to_as_employee(Activities, :create, :activity => { 
      :date => Date.today,
      :project_id => Project.gen.id,
      :hours => "6:30",
      :comments => "",
    })
    response.status.should == 200
  end
  
  it "should not add activity for other user if he isn't admin" do
    @employee = Employee.gen
    other_user = Employee.gen
    proc do
      proc do
        response = dispatch_to_as_employee(Activities, :create, :activity => { 
          :date => Date.today,
          :project_id => Project.gen.id,
          :hours => "7",
          :comments => "this & that",
          :user_id => other_user.id
        })
        response.status.should == 201
      end.should change(@employee.activities, :count).by(1)
    end.should_not change(other_user.activities, :count)
  end
  
  it "should add activity for other user if he is admin" do
    @admin = Employee.gen(:admin)
    other_user = Employee.gen
    proc do
      proc do
        response = dispatch_to_as_admin(Activities, :create, :activity => { 
          :date => Date.today,
          :project_id => Project.gen.id,
          :hours => "7",
          :comments => "this & that",
          :user_id => other_user.id
        })
        response.status.should == 201
      end.should_not change(@admin.activities, :count)
    end.should change(other_user.activities, :count).by(1)
  end
  
  it "should match /users/3/calendar to Activites#calendar with user_id = 3" do
    request_to("/users/3/calendar", :get).should route_to(Activities, :calendar)
  end
  
  it "should be successful for user requesting for his calendar" do
    prepare_users
    controller = as(@employee).dispatch_to(Activities, :calendar, :user_id => @employee.id).should be_successful
  end
  
  it "should be successful for admin requesting for user's calendar" do
    prepare_users    
    as(:admin).dispatch_to(Activities, :calendar, :user_id => @employee.id).should be_successful
  end
  
  it "should raise forbidden for trying to view other's calendars" do
    block_should(raise_forbidden) do
      as(Employee.gen).dispatch_to(Activities, :calendar, :user_id => Employee.gen.id)
    end
  end

  it "should render calendar for particular month" do
    user = Employee.gen
    user.activities.should_receive(:for).with(:this_month)
    as(user).dispatch_to(Activities, :calendar).should be_successful
  end
end
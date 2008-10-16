require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Activities, "index action" do
  include ControllerSpecsHelper

  it "should show 3 recent and rest of projects when adding new activity" do
    Project.all.destroy!
    Activity.all.destroy!
    
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
    other_projects.size.should == Project.active.count - 3# (3 + 15 + 1) - (3 recent + 1 inactive)
  end
end
require 'spec_helper'

describe Project do

  it "should be created" do
    block_should(change(Project, :count).by(1)) do
      Project.make.save.should be_true
    end
  end

  describe "#visible_for" do
    before :each do
      @client = Client.generate

      @active = Project.generate :active => true, :client => @client
      @inactive = Project.generate :active => false, :client => @client

      @active_with_activity = Project.generate :active => true, :client => @client
      @inactive_with_activity = Project.generate :active => false, :client => @client
      [@active_with_activity, @inactive_with_activity].each { |p| Activity.generate :project => p }
    end

    it "should return any project for admin" do
      admin = Employee.make(:admin)
      found = Project.visible_for(admin)
      [@active, @inactive, @active_with_activity, @inactive_with_activity].each { |p| found.should include(p) }
    end

    it "should return only active projects for employee" do
      user = Employee.make
      found = Project.visible_for(user)
      [@active_with_activity, @active].each { |p| found.should include(p) }
      [@inactive_with_activity, @inactive].each { |p| found.should_not include(p) }
    end

    it "should only include client's projects for client" do
      other_client = Client.generate
      other_clients_user = ClientUser.generate :client => other_client
      other_project = Project.generate :client => other_client

      found = Project.visible_for(other_clients_user)
      found.should include(other_project)

      [@active, @inactive, @active_with_activity, @inactive_with_activity].each { |p| found.should_not include(p) }
    end
  end

  describe "#with_activities_for" do
    it "should include projects with activities added by user" do
      project = Project.gen
      user = Employee.gen
      Activity.gen :user => user, :project => project

      Project.with_activities_for(user).should include(project)
    end

    it "should not include projects for which the user hasn't added any activities" do
      project = Project.gen
      user1 = Employee.gen
      user2 = Employee.gen
      Activity.gen :user => user1, :project => project
      Project.with_activities_for(user2).should_not include(project)
    end

    it "should not include duplicate entries" do
      project = Project.gen
      user = Employee.gen
      2.times { Activity.gen :user => user, :project => project }
      Project.with_activities_for(user).should == [project]
    end
  end

  describe "calendar_viewable?" do
    before :each do
      @client = Client.gen
      @project = Project.gen :client => @client
    end

    it "should be viewable by client's users" do
      user = ClientUser.gen :client => @client
      @project.calendar_viewable?(user).should be_true
    end

    it "should NOT be viewable by other clients' users" do
      user = ClientUser.gen
      @project.calendar_viewable?(user).should be_false
    end

    it "should be viewable by admin" do
      admin = User.gen :admin
      @project.calendar_viewable?(admin).should be_true
    end
  end

end

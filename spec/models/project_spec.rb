require 'spec_helper'

describe Project do

  it "should be created" do
    block_should(change(Project, :count).by(1)) do
      Project.prepare.save.should be_true
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
      admin = Employee.prepare(:admin)
      found = Project.visible_for(admin)
      [@active, @inactive, @active_with_activity, @inactive_with_activity].each { |p| found.should include(p) }
    end

    it "should return only active projects for employee" do
      user = Employee.prepare
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
      project = Project.generate
      user = Employee.generate
      Activity.generate :user => user, :project => project

      Project.with_activities_for(user).should include(project)
    end

    it "should not include projects for which the user hasn't added any activities" do
      project = Project.generate
      user1 = Employee.generate
      user2 = Employee.generate
      Activity.generate :user => user1, :project => project
      Project.with_activities_for(user2).should_not include(project)
    end

    it "should not include duplicate entries" do
      project = Project.generate
      user = Employee.generate
      2.times { Activity.generate :user => user, :project => project }
      Project.with_activities_for(user).should == [project]
    end
  end

  describe "#activity_type_ids" do
    it "should return ids of assigned activity types" do
      project = Project.generate!(:client => Client.generate!)
      activity_type_1 = ActivityType.generate!
      activity_type_2 = ActivityType.generate!

      project.activity_types << activity_type_1
      project.activity_types << activity_type_2
      project.save

      project.activity_type_ids.count.should == 2
      project.activity_type_ids.should include(activity_type_1.id)
      project.activity_type_ids.should include(activity_type_2.id)
    end
  end

  describe "#activity_type_ids=" do
    it "should assign proper activity types" do
      project = Project.generate!(:client => Client.generate!)
      activity_type_1 = ActivityType.generate!
      activity_type_2 = ActivityType.generate!
      activity_type_3 = ActivityType.generate!

      project.activity_types << activity_type_1
      project.activity_types << activity_type_2
      project.save

      project.activity_type_ids = [activity_type_1.id, activity_type_3.id]

      project.activity_types.reload
      project.activity_types.count.should == 2
      project.activity_types.should include(activity_type_1)
      project.activity_types.should include(activity_type_3)
    end
  end

  describe "calendar_viewable?" do
    before :each do
      @client = Client.generate
      @project = Project.generate :client => @client
    end

    it "should be viewable by client's users" do
      user = ClientUser.generate :client => @client
      @project.calendar_viewable?(user).should be_true
    end

    it "should NOT be viewable by other clients' users" do
      user = ClientUser.generate
      @project.calendar_viewable?(user).should be_false
    end

    it "should be viewable by admin" do
      admin = User.generate :admin
      @project.calendar_viewable?(admin).should be_true
    end
  end

end

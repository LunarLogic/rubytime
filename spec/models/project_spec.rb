require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  it "should be created" do
    block_should(change(Project, :count).by(1)) do
      Project.make(:client => fx(:orange)).save.should be_true
    end
  end
  
  it "should find active projects" do
    Project.count.should == 9
    Project.active.count.should == 7
  end

  describe "visible_for" do
    before :each do
      @client = Client.generate!
      @active = Project.generate! :active => true, :client => @client
      @inactive = Project.generate! :active => false, :client => @client
      @active_with_activity = Project.generate! :active => true, :client => @client
      @inactive_with_activity = Project.generate! :active => false, :client => @client
      Activity.generate! :project => @active_with_activity
      Activity.generate! :project => @inactive_with_activity
    end

    it "should return any project for admin" do
      found = Project.visible_for(fx(:admin))
      [@active, @inactive, @active_with_activity, @inactive_with_activity].each { |p| found.should include(p) }
    end

    it "should return only active projects for employee" do
      found = Project.visible_for(fx(:stefan))
      [@active_with_activity, @active].each { |p| found.should include(p) }
      [@inactive_with_activity, @inactive].each { |p| found.should_not include(p) }
    end

    it "should only include client's projects for client" do
      client = Client.generate!
      client_user = ClientUser.generate! :client => client
      client_project = Project.generate! :client => client
      found = Project.visible_for(client_user)
      found.should include(client_project)
      [@active, @inactive, @active_with_activity, @inactive_with_activity].each { |p| found.should_not include(p) }
    end
  end

  describe "with_activities_for" do
    before :each do
      @user = Employee.generate!
      @user2 = Employee.generate!
      @client = Client.generate!
      @project = Project.generate! :client => @client
    end

    it "should include projects with activities added by user" do
      Activity.generate! :user => @user, :project => @project
      Project.with_activities_for(@user).should include(@project)
    end

    it "should not include projects for which the user hasn't added any activities" do
      Activity.generate! :user => @user2, :project => @project
      Project.with_activities_for(@user).should_not include(@project)
    end

    it "should not include duplicate entries" do
      2.times { Activity.generate! :user => @user, :project => @project }
      Project.with_activities_for(@user).length.should == 1
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

end

require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  it "should be created" do
    block_should(change(Project, :count).by(1)) do
      Project.make(:client => fx(:orange)).save.should be_true
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
      found = Project.visible_for(fx(:admin))
      [@active, @inactive, @active_with_activity, @inactive_with_activity].each { |p| found.should include(p) }
    end

    it "should return only active projects for employee" do
      found = Project.visible_for(fx(:stefan))
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
    before :each do
      @stefan = fx(:stefan)
      @lazy_dev = fx(:lazy_dev)
      @apple = fx(:apple)
      @project = fx(:apples_first_project)
    end

    it "should include projects with activities added by user" do
      Project.with_activities_for(@stefan).should include(@project)
    end

    it "should not include projects for which the user hasn't added any activities" do
      Project.with_activities_for(@lazy_dev).should_not include(@project)
    end

    it "should not include duplicate entries" do
      @stefan.activities.destroy!
      Activity.generate! :user => @stefan, :project => @project
      Project.with_activities_for(@stefan).length.should == 1
    end
  end

end

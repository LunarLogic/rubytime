require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  it "should be created" do
    block_should(change(Project, :count).by(1)) do
      Project.make(:client => fx(:orange)).save.should be_true
    end
  end
  
  describe "#visible_for" do
    before :each do
      @client = fx(:peach)

      @active = fx(:peaches_first_project)
      @inactive = fx(:peaches_inactive_project)

      @active_with_activity = fx(:oranges_first_project)
      @inactive_with_activity = fx(:oranges_inactive_project)

      [@inactive, @inactive_with_activity].each { |p| p.update(:active => false) }
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
      found = Project.visible_for(fx(:apple_user1))
      found.should include(fx(:apples_first_project))

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

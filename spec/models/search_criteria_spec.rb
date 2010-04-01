require 'spec_helper'

describe SearchCriteria do

  before :all do
    @admin = Employee.generate(:admin)
    @devs = Role.generate
    @testers = Role.generate
    @dev1 = Employee.generate :role => @devs
    @dev2 = Employee.generate :role => @devs
    @tester1 = Employee.generate :role => @testers
    @tester2 = Employee.generate :role => @testers

    @apple = Client.generate
    @project_apple_a = Project.generate :client => @apple
    @project_apple_b = Project.generate :client => @apple
    @activity_apple_a1 = Activity.generate :project => @project_apple_a, :user => @dev1
    @activity_apple_a2 = Activity.generate :project => @project_apple_a, :user => @tester1
    @activity_apple_b1 = Activity.generate :project => @project_apple_b, :user => @dev2
    @activity_apple_b2 = Activity.generate :project => @project_apple_b, :user => @tester2
    
    @banana = Client.generate
    @project_banana_a = Project.generate :client => @banana
    @project_banana_b = Project.generate :client => @banana
    @project_banana_c = Project.generate :client => @banana
    @activity_banana_a1 = Activity.generate :project => @project_banana_a, :user => @dev1
    @activity_banana_a2 = Activity.generate :project => @project_banana_a, :user => @tester1
    @activity_banana_b1 = Activity.generate :project => @project_banana_b, :user => @dev2
    @activity_banana_b2 = Activity.generate :project => @project_banana_b, :user => @tester2
    @activity_banana_c1 = Activity.generate :project => @project_banana_c, :user => @admin

    @project_banana_inactive = Project.generate :client => @banana, :active => false
    @activity_banana_inactive_1 = Activity.generate :project => @project_banana_inactive
    @activity_banana_inactive_2 = Activity.generate :project => @project_banana_inactive

    @orange = Client.generate
    @project_orange_a = Project.generate :client => @orange
    @project_orange_b = Project.generate :client => @orange
    @activity_orange_a1 = Activity.generate :project => @project_orange_a, :user => @dev1
    @activity_orange_a2 = Activity.generate :project => @project_orange_a, :user => @tester1
    @activity_orange_b1 = Activity.generate :project => @project_orange_b, :user => @dev2
    @activity_orange_b2 = Activity.generate :project => @project_orange_b, :user => @tester2
  end

  def search(client, attributes, fields = {})
    user = client.is_a?(User) ? client : ClientUser.first_or_generate(:client => client)
    sc = SearchCriteria.new(attributes, user)
    fields.each do |key, value|
      sc.send("#{key}=", value)
    end
    sc.found_activities
  end

  def search_all(*args)
    search(@admin, *args)
  end

  context "for admin" do

    it "should return all activities" do
      list = search_all({})
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_b2)
      list.should include(@activity_orange_a2)
      list.should_not include(@activity_banana_inactive_1)

      list2 = search_all({ :project_id => [''], :user_id => [''] })
      list2.should == list

      list3 = search_all({}, { :include_inactive_projects => true })
      (list - list3).should == []
      list3.should include(@activity_banana_inactive_1)
      list3.should include(@activity_banana_inactive_2)
    end

    it "should return 'graphic_design' activities for specific project" do
      sc = SearchCriteria.new({ :project_id => [fx(:oranges_second_project).id], :activity_type_id => [fx(:graphic_design).id] }, fx(:admin))
      sc.should have(6).found_activities
    end

    it "should return 'design' activities for specific project" do
      sc = SearchCriteria.new({ :project_id => [fx(:oranges_second_project).id], :activity_type_id => [fx(:design).id] }, fx(:admin))
      sc.should have(6).found_activities
    end

    it "should return 'graphic_design' activities for two specific projects" do
      sc = SearchCriteria.new({ :project_id => [fx(:oranges_second_project).id, fx(:apples_first_project).id], :activity_type_id => [fx(:graphic_design).id] }, fx(:admin))
      sc.should have(6).found_activities
    end

    it "should return 'coding' and 'graphic_design' activities for two specific projects" do
      sc = SearchCriteria.new({ :project_id => [fx(:oranges_second_project).id, fx(:apples_first_project).id], :activity_type_id => [fx(:coding).id, fx(:graphic_design).id] }, fx(:admin))
      sc.should have(12).found_activities
    end

    it "should return all activities for specific client" do
      list = search_all({ :client_id => [@banana.id] })
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_b2)
      list.should_not include(@activity_banana_inactive_1)
      list.should_not include(@activity_orange_a1)

      list2 = search_all({ :client_id => [@banana.id] }, { :include_inactive_projects => true })
      (list - list2).should == []
      list2.should include(@activity_banana_inactive_1)
      list2.should_not include(@activity_orange_a1)

      list3 = search_all({ :client_id => [@orange.id] })
      list3.should_not include(@activity_banana_a1)
      list3.should include(@activity_orange_a1)
    end

    it "should return all activities for two clients" do
      list = search_all({ :client_id => [@banana.id, @orange.id] })
      list.should include(@activity_banana_a1)
      list.should include(@activity_orange_b2)
      list.should_not include(@activity_banana_inactive_1)
      list.should_not include(@activity_apple_a1)

      list2 = search_all({ :client_id => [@banana.id, @orange.id] }, { :include_inactive_projects => true })
      list2.should include(@activity_banana_inactive_1)
      list2.should_not include(@activity_apple_a1)
    end

    it "should return all activities for specific project" do
      list = search_all({ :project_id => [@project_banana_a.id] })
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_a2)
      list.should_not include(@activity_banana_b1)
      list.should_not include(@activity_orange_a1)
    end

    it "should return all activities for two project of same client" do
      list = search_all({ :project_id => [@project_banana_a.id, @project_banana_b.id] })
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_b1)
      list.should_not include(@activity_banana_c1)
      list.should_not include(@activity_orange_a1)
    end

    it "should return all activities for two project of different clients" do
      list = search_all({ :project_id => [@project_banana_a.id, @project_orange_b.id] })
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_a2)
      list.should_not include(@activity_banana_b1)
      list.should_not include(@activity_orange_a1)
      list.should include(@activity_orange_b1)
    end

    it "should return all activities for specific role" do
      dev1_activity = Activity.generate :user => @dev1, :project => @project_banana_a
      dev2_activity = Activity.generate :user => @dev2, :project => @project_banana_a
      dev2_activity_inactive = Activity.generate :user => @dev2, :project => @project_banana_inactive
      tester1_activity = Activity.generate :user => @tester1, :project => @project_banana_a
      admin_activity = Activity.generate :user => @admin, :project => @project_banana_a

      list = search_all({ :role_id => [@devs.id] })
      list.should include(dev1_activity)
      list.should include(dev2_activity)
      list.should_not include(tester1_activity)
      list.should_not include(admin_activity)
      list.should_not include(dev2_activity_inactive)

      list2 = search_all({ :role_id => [@devs.id] }, { :include_inactive_projects => true })
      list2.should include(dev2_activity_inactive)
      list2.should_not include(tester1_activity)
      list2.should_not include(admin_activity)
    end

    it "should return all activities for specific user" do
      dev1_activity = Activity.generate :user => @dev1, :project => @project_banana_a
      dev2_activity = Activity.generate :user => @dev2, :project => @project_banana_a

      list = search_all({ :user_id => [@dev1.id] })
      list.should include(dev1_activity)
      list.should_not include(dev2_activity)
    end

    it "should return all activities for two users" do
      dev1_activity = Activity.generate :user => @dev1, :project => @project_banana_a
      dev2_activity = Activity.generate :user => @dev2, :project => @project_banana_a
      tester1_activity = Activity.generate :user => @tester1, :project => @project_banana_a

      list = search_all({ :user_id => [@dev1.id, @tester1.id] })
      list.should include(dev1_activity)
      list.should_not include(dev2_activity)
      list.should include(tester1_activity)
    end

    it "should return all activities for specific client and role" do
      dev1_activity_banana = Activity.generate :user => @dev1, :project => @project_banana_a
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      tester1_activity_banana = Activity.generate :user => @tester1, :project => @project_banana_a
      tester1_activity_orange = Activity.generate :user => @tester1, :project => @project_orange_a

      list = search_all({ :client_id => [@banana.id], :role_id => [@testers.id] })
      list.should include(tester1_activity_banana)
      list.should_not include(tester1_activity_orange)
      list.should_not include(dev1_activity_banana)
      list.should_not include(dev1_activity_orange)
    end

    it "should return all activities for specific project and user" do
      dev1_activity_banana_a = Activity.generate :user => @dev1, :project => @project_banana_a
      dev1_activity_banana_b = Activity.generate :user => @dev1, :project => @project_banana_b
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      dev2_activity_banana_a = Activity.generate :user => @dev2, :project => @project_banana_a
      dev2_activity_banana_b = Activity.generate :user => @dev2, :project => @project_banana_b

      list = search_all({ :project_id => [@project_banana_a.id], :user_id => [@dev1.id] })
      list.should include(dev1_activity_banana_a)
      list.should_not include(dev1_activity_banana_b)
      list.should_not include(dev1_activity_orange)
      list.should_not include(dev2_activity_banana_a)
      list.should_not include(dev2_activity_banana_b)
    end

  end


  context "for client" do

    it "should return all client's activities" do
      list = search(@orange, {})
      list.should include(@activity_orange_a1)
      list.should include(@activity_orange_b2)
      list.should_not include(@activity_banana_a1)
      list.should_not include(@activity_apple_b1)

      list = search(@banana, {})
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_b1)
      list.should_not include(@activity_banana_inactive_1)
      list.should_not include(@activity_orange_a1)
      list.should_not include(@activity_apple_b1)

      list = search(@banana, {}, { :include_inactive_projects => true })
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_b1)
      list.should include(@activity_banana_inactive_1)
      list.should_not include(@activity_orange_a1)
      list.should_not include(@activity_apple_b1)
    end

    it "should return all activities for specific project" do
      list = search(@orange, { :project_id => [@project_orange_b.id] })
      list.should include(@activity_orange_b1)
      list.should include(@activity_orange_b2)
      list.should_not include(@activity_orange_a1)
      list.should_not include(@activity_banana_b1)
    end

    it "should return all activities for two projects" do
      list = search(@banana, { :project_id => [@project_banana_a.id, @project_banana_c.id] })
      list.should include(@activity_banana_a1)
      list.should include(@activity_banana_a2)
      list.should include(@activity_banana_c1)
      list.should_not include(@activity_banana_b1)
      list.should_not include(@activity_orange_a1)
    end

    it "should return all activities for specific role" do
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      dev2_activity_orange = Activity.generate :user => @dev2, :project => @project_orange_b
      dev2_activity_banana = Activity.generate :user => @dev2, :project => @project_banana_c
      tester1_activity_orange = Activity.generate :user => @tester1, :project => @project_orange_a

      list = search(@orange, { :role_id => [@devs.id] })
      list.should include(dev1_activity_orange)
      list.should include(dev2_activity_orange)
      list.should_not include(dev2_activity_banana)
      list.should_not include(tester1_activity_orange)
    end

    it "should return all activities for specific user" do
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      dev2_activity_orange = Activity.generate :user => @dev2, :project => @project_orange_b
      dev2_activity_banana = Activity.generate :user => @dev2, :project => @project_banana_c
      tester1_activity_orange = Activity.generate :user => @tester1, :project => @project_orange_a

      list = search(@orange, { :user_id => [@dev2.id] })
      list.should_not include(dev1_activity_orange)
      list.should include(dev2_activity_orange)
      list.should_not include(dev2_activity_banana)
      list.should_not include(tester1_activity_orange)
    end

    it "should return all activities for two users" do
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      dev2_activity_orange = Activity.generate :user => @dev2, :project => @project_orange_b
      dev2_activity_banana = Activity.generate :user => @dev2, :project => @project_banana_c
      tester1_activity_orange = Activity.generate :user => @tester1, :project => @project_orange_a

      list = search(@orange, { :user_id => [@dev2.id, @tester1.id] })
      list.should_not include(dev1_activity_orange)
      list.should include(dev2_activity_orange)
      list.should_not include(dev2_activity_banana)
      list.should include(tester1_activity_orange)
    end

    it "should return all activities for specific project and user" do
      dev1_activity_orange1 = Activity.generate :user => @dev1, :project => @project_orange_a
      dev1_activity_orange2 = Activity.generate :user => @dev1, :project => @project_orange_b
      dev2_activity_orange2 = Activity.generate :user => @dev2, :project => @project_orange_b

      list = search(@orange, { :project_id => [@project_orange_b.id], :user_id => [@dev1.id] })
      list.should include(dev1_activity_orange2)
      list.should_not include(dev1_activity_orange1)
      list.should_not include(dev2_activity_orange2)
    end
  end

  context "for standard employee" do

    it "should return all user's activities" do
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      dev1_activity_banana = Activity.generate :user => @dev1, :project => @project_banana_b
      dev2_activity_banana = Activity.generate :user => @dev2, :project => @project_banana_b
      tester1_activity_banana = Activity.generate :user => @tester1, :project => @project_banana_b

      list = search(@dev1, {})
      list.should include(dev1_activity_banana)
      list.should include(dev1_activity_orange)
      list.should_not include(dev2_activity_banana)
      list.should_not include(tester1_activity_banana)

      list2 = search(@dev2, {})
      list2.should include(dev2_activity_banana)
      list2.should_not include(dev1_activity_banana)
      list2.should_not include(tester1_activity_banana)
    end

    it "should return all activities for specific client" do
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_a
      dev1_activity_banana = Activity.generate :user => @dev1, :project => @project_banana_b
      dev2_activity_banana = Activity.generate :user => @dev2, :project => @project_banana_b

      list = search(@dev1, { :client_id => [@banana.id] })
      list.should include(dev1_activity_banana)
      list.should_not include(dev1_activity_orange)
      list.should_not include(dev2_activity_banana)
    end

    it "should return all activities for two clients" do
      dev1_activity_apple = Activity.generate :user => @dev1, :project => @project_apple_a
      dev1_activity_banana = Activity.generate :user => @dev1, :project => @project_banana_c
      dev1_activity_orange = Activity.generate :user => @dev1, :project => @project_orange_b

      list = search(@dev1, { :client_id => [@orange.id, @banana.id] })
      list.should include(dev1_activity_banana)
      list.should include(dev1_activity_orange)
      list.should_not include(dev1_activity_apple)
    end
  
    it "should return all activities for specific project" do
      dev1_activity_orange_a = Activity.generate :user => @dev1, :project => @project_orange_a
      dev1_activity_orange_b = Activity.generate :user => @dev1, :project => @project_orange_b
      dev1_activity_banana_c = Activity.generate :user => @dev1, :project => @project_banana_c
      dev2_activity_orange_a = Activity.generate :user => @dev2, :project => @project_orange_a

      list = search(@dev1, { :project_id => [@project_orange_a.id] })
      list.should include(dev1_activity_orange_a)
      list.should_not include(dev1_activity_orange_b)
      list.should_not include(dev1_activity_banana_c)
      list.should_not include(dev2_activity_orange_a)
    end

    it "should return all activities for two project of same client" do
      dev1_activity_banana_a = Activity.generate :user => @dev1, :project => @project_banana_a
      dev1_activity_banana_b = Activity.generate :user => @dev1, :project => @project_banana_b
      dev1_activity_banana_c = Activity.generate :user => @dev1, :project => @project_banana_c
      dev2_activity_banana_c = Activity.generate :user => @dev2, :project => @project_banana_c

      list = search(@dev1, { :project_id => [@project_banana_b.id, @project_banana_c.id] })
      list.should include(dev1_activity_banana_b)
      list.should include(dev1_activity_banana_c)
      list.should_not include(dev1_activity_banana_a)
      list.should_not include(dev2_activity_banana_c)
    end
  
    it "should return all activities for two project of different clients" do
      dev1_activity_banana_a = Activity.generate :user => @dev1, :project => @project_banana_a
      dev1_activity_banana_b = Activity.generate :user => @dev1, :project => @project_banana_b
      dev1_activity_orange_a = Activity.generate :user => @dev1, :project => @project_orange_a
      dev1_activity_orange_b = Activity.generate :user => @dev1, :project => @project_orange_b
      dev2_activity_banana_a = Activity.generate :user => @dev2, :project => @project_banana_a

      list = search(@dev1, { :project_id => [@project_banana_a.id, @project_orange_b.id] })
      list.should include(dev1_activity_banana_a)
      list.should include(dev1_activity_orange_b)
      list.should_not include(dev1_activity_banana_b)
      list.should_not include(dev1_activity_orange_a)
      list.should_not include(dev2_activity_banana_a)
    end

  end


  describe ":include_inactive_projects attribute" do
    it "should not be settable via constructor" do
      sc = SearchCriteria.new({ :include_inactive_projects => true  }, User.first)
      sc.include_inactive_projects.should == false
      sc = SearchCriteria.new({ :include_inactive_projects => false }, User.first)
      sc.include_inactive_projects.should == false
    end

    it "should only be settable via setter" do
      sc = SearchCriteria.new({}, User.first)
      sc.include_inactive_projects = true
      sc.include_inactive_projects.should == true
      sc.include_inactive_projects = false
      sc.include_inactive_projects.should == false
    end
  end

end

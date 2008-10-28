require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe SearchCriteria do
  before(:all) do
    @client1 = Client.gen
    @client2 = Client.gen
    @client3 = Client.gen
    3.times { Project.gen(:client => @client1) }
    Project.gen(:client => @client1, :active => false) # this shouldn't be counted
    4.times { Project.gen(:client => @client2) }
    Project.gen(:client => @client2, :active => false) # this shouldn't be counted
    5.times { Project.gen(:client => @client3) }
    Project.gen(:client => @client3, :active => false) # this shouldn't be counted
    @role1 = Role.gen
    @role2 = Role.gen
    @admin = Employee.gen(:admin)
    @dev1 = Employee.gen(:role => @role1)
    @dev2 = Employee.gen(:role => @role1)
    @dev3 = Employee.gen(:role => @role2)
    @client_user1 = ClientUser.gen(:client => @client1)
    @client_user2 = ClientUser.gen(:client => @client2)
    @client_user3 = ClientUser.gen(:client => @client3)

    # 3 projects * (2 + 1 + 1) = 12 activities
    @client1.projects.each do |project|
      2.times { Activity.gen(:project => project, :user => @dev1) } # 3 * 2 = 6
      Activity.gen(:project => project, :user => @dev2) # 3 * 1 = 3
      Activity.gen(:project => project, :user => @dev3) # 3 * 1 = 3
    end
    
    # 4 projects * (1 + 2 + 1) = 16 activities
    @client2.projects.each do |project|
      Activity.gen(:project => project, :user => @dev1) # 4 * 1 = 4
      2.times { Activity.gen(:project => project, :user => @dev2) } # 4 * 2 = 8
      Activity.gen(:project => project, :user => @dev3) # 4 * 1 = 4
    end

    # 5 projects * (1 + 1 + 2) = 20 activities
    @client3.projects.each do |project|
      Activity.gen(:project => project, :user => @dev1) # 5 * 1 = 5
      Activity.gen(:project => project, :user => @dev2) # 5 * 1 = 5
      2.times { Activity.gen(:project => project, :user => @dev3) } # 5 * 2 = 10
    end
    
    # dev1: 6 + 4 + 5 = 15 activities
    # dev2: 3 + 8 + 5 = 16 activities
    # dev3: 3 + 4 + 10 = 17 activities
    # total of: 15 + 16 + 17 = 48 activities
  end
  
  # admin
  
  it "should return all activities (for admin)" do
    user = fx(:admin)
    sc = SearchCriteria.new({}, user)
    sc.should have(48).found_activities
    sc = SearchCriteria.new({ :project_id => [""], :user_id => [""] }, user)
    sc.should have(48).found_activities
  end

  it "should return all activities for specific client (for admin)" do
    sc = SearchCriteria.new({ :client_id => [@client1.id] }, @admin)
    sc.should have(12).found_activities
  end

  it "should return all activities for two clients (for admin)" do
    clients = [@client1, @client2]
    sc = SearchCriteria.new({ :client_id => [clients[0].id, clients[1].id] }, @admin)
    sc.should have(12 + 16).found_activities
  end
  
  it "should return all activities for specific project (for admin)" do
    project = Project.active.first
    sc = SearchCriteria.new({ :project_id => [project.id] }, @admin)
    sc.should have(project.activities.count).found_activities
  end

  it "should return all activities for two project of same client (for admin)" do
    projects = Project.active.all(:limit => 2, :order => [:id])
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, @admin)
    sc.should have(projects[0].activities.count + projects[1].activities.count).found_activities
  end
  
  it "should return all activities for two project of different clients (for admin)" do
    clients = [@client1, @client2]
    projects = [clients[0].projects.active.first, clients[1].projects.active.first]
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, @admin)
    sc.should have(projects[0].activities.count + projects[1].activities.count).found_activities
  end
  
  it "should return all activities for specific role (for admin)" do
    sc = SearchCriteria.new({ :role_id => [@role1.id] }, @admin)
    sc.should have(15 + 16).found_activities

    sc = SearchCriteria.new({ :role_id => [@role2.id] }, @admin)
    sc.should have(17).found_activities
  end

  it "should return all activities for specific user (for admin)" do
    sc = SearchCriteria.new({ :user_id => [@dev1.id] }, @admin)
    sc.should have(15).found_activities
  end

  it "should return all activities for two users (for admin)" do
    sc = SearchCriteria.new({ :user_id => [@dev1.id, @dev3.id] }, @admin)
    sc.should have(15 + 17).found_activities
  end

  it "should return all activities for specific client and role (for admin)" do
    sc = SearchCriteria.new({ :client_id => [@client3.id], :role_id => [@role1.id] }, @admin)
    sc.should have(5 + 5).found_activities
  end

  it "should return all activities for specific project and user (for admin)" do
    sc = SearchCriteria.new({ :project_id => [@client3.projects.active.first.id], :user_id => [@dev3.id] }, @admin)
    sc.should have(2).found_activities
    
    sc = SearchCriteria.new({ :project_id => [@client3.projects.active.first.id], :user_id => [@dev2.id] }, @admin)
    sc.should have(1).found_activities
  end


  # client
  
  it "should return all activities (for client)" do
    client_user = @client_user1
    client = client_user.client
    sc = SearchCriteria.new({}, client_user)
    sc.should have(12).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
    
    client_user = @client_user2
    client = client_user.client
    sc = SearchCriteria.new({}, client_user)
    sc.should have(16).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
    
    client_user = @client_user3
    client = client_user.client
    sc = SearchCriteria.new({}, client_user)
    sc.should have(20).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for specific project (for client)" do
    client_user = @client_user1
    client = client_user.client
    project = client.projects.active.first
    sc = SearchCriteria.new({ :project_id => [project.id] }, client_user)
    sc.should have(project.activities.count).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for two projects (for client)" do
    client_user = @client_user2
    client = client_user.client
    projects = client.projects.active.all(:limit => 2)
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, client_user)
    sc.should have(projects[0].activities.count + projects[1].activities.count).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end
  
  it "should return all activities for specific role (for client)" do
    client_user = @client_user3
    client = client_user.client
    sc = SearchCriteria.new({ :role_id => [@role1.id] }, client_user)
    sc.should have(10).found_activities
    sc = SearchCriteria.new({ :role_id => [@role2.id] }, client_user)
    sc.should have(10).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for specific user (for client)" do
    client_user = @client_user1
    client = client_user.client
    sc = SearchCriteria.new({ :user_id => [@dev1.id] }, client_user)
    sc.should have(6).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for two users (for client)" do
    client_user = @client_user1
    client = client_user.client
    sc = SearchCriteria.new({ :user_id => [@dev1.id, @dev3.id] }, client_user)
    sc.should have(6 + 3).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for specific project and user (for client)" do
    client_user = @client_user2
    client = client_user.client
    project = client.projects.active.first
    sc = SearchCriteria.new({ :project_id => [project.id], :user_id => [@dev2.id] }, client_user)
    sc.should have(2).found_activities
    sc = SearchCriteria.new({ :project_id => [project.id], :user_id => [@dev3.id] }, client_user)
    sc.should have(1).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end
  
  it "shouldn't return any activities for other client's projects (for client)" do
    client_user = @client_user1
    client = client_user.client
    other_client = @client2
    sc = SearchCriteria.new({ :client_id => [other_client.id] }, client_user)
    sc.found_activities.each do |activity|
      activity.project.client_id.should_not == other_client.id
    end
  end

  it "shouldn't return any activities for other client's project (for client)" do
    client_user = @client_user1
    client = client_user.client
    project = client.projects.active.first
    other_client = @client2
    other_clients_project = other_client.projects.active.first
    sc = SearchCriteria.new({ :project_id => [other_clients_project.id] }, client_user)
    sc.found_activities.each do |activity|
      activity.project.client_id.should_not == other_client.id
    end
  end

  
  # employee
  
  it "should return all activities (for employee)" do
    user = @dev1
    sc = SearchCriteria.new({}, user)
    sc.should have(15).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end

    user = @dev2
    sc = SearchCriteria.new({}, user)
    sc.should have(16).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end

    user = @dev3
    sc = SearchCriteria.new({}, user)
    sc.should have(17).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "should return all activities for specific client (for employee)" do
    user = @dev1
    sc = SearchCriteria.new({ :client_id => [@client1.id] }, user)
    sc.should have(6).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "should return all activities for two clients (for employee)" do
    user = @dev2
    clients = [@client1, @client2]
    sc = SearchCriteria.new({ :client_id => [clients[0].id, clients[1].id] }, user)
    sc.should have(3 + 8).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end
  
  it "should return all activities for specific project (for employee)" do
    user = @dev3
    project = Project.active.first
    sc = SearchCriteria.new({ :project_id => [project.id] }, user)
    sc.should have(project.activities.count(:user_id => user.id)).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "should return all activities for two project of same client (for employee)" do
    user = @dev1
    projects = Project.active.all(:limit => 2, :order => [:id])
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, user)
    sc.should have(projects[0].activities.count(:user_id => user.id) + 
                   projects[1].activities.count(:user_id => user.id)).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end
  
  it "should return all activities for two project of different clients (for employee)" do
    user = @dev2
    clients = [@client1, @client2]
    projects = [clients[0].projects.active.first, clients[1].projects.active.first]
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, user)
    sc.should have(projects[0].activities.count(:user_id => user.id) + 
                   projects[1].activities.count(:user_id => user.id)).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "shouldn't return any activities for other user (for employee)" do
    user = @dev3
    other_user = @dev1
    sc = SearchCriteria.new({ :user_id => [other_user.id] }, user)
    sc.found_activities.each do |activity|
      activity.user_id.should_not == other_user.id
    end
  end
end

require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe SearchCriteria do
  # admin
  
  it "should return all activities (for admin)" do
    user = fx(:admin)
    sc = SearchCriteria.new({}, user)
    sc.should have(42).found_activities
    sc = SearchCriteria.new({ :project_id => [""], :user_id => [""] }, user)
    sc.should have(42).found_activities
  end

  it "should return all activities for specific client (for admin)" do
    sc = SearchCriteria.new({ :client_id => [fx(:orange).id] }, fx(:admin))
    sc.should have(18).found_activities
  end

  it "should return all activities for two clients (for admin)" do
    clients = [fx(:orange), fx(:apple)]
    sc = SearchCriteria.new({ :client_id => [clients[0].id, clients[1].id] }, fx(:admin))
    sc.should have(18 + 18).found_activities
  end
  
  it "should return all activities for specific project (for admin)" do
    project = Project.active.first
    sc = SearchCriteria.new({ :project_id => [project.id] }, fx(:admin))
    sc.should have(project.activities.count).found_activities
  end

  it "should return all activities for two project of same client (for admin)" do
    projects = Project.active.all(:limit => 2, :order => [:id])
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, fx(:admin))
    sc.should have(projects[0].activities.count + projects[1].activities.count).found_activities
  end
  
  it "should return all activities for two project of different clients (for admin)" do
    clients = [fx(:orange), fx(:apple)]
    projects = [clients[0].projects.active.first, clients[1].projects.active.first]
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, fx(:admin))
    sc.should have(projects[0].activities.count + projects[1].activities.count).found_activities
  end
  
  it "should return all activities for specific role (for admin)" do
    sc = SearchCriteria.new({ :role_id => [fx(:developer).id] }, fx(:admin))
    sc.should have(28).found_activities

    sc = SearchCriteria.new({ :role_id => [fx(:tester).id] }, fx(:admin))
    sc.should have(14).found_activities
  end

  it "should return all activities for specific user (for admin)" do
    sc = SearchCriteria.new({ :user_id => [fx(:jola).id] }, fx(:admin))
    sc.should have(19).found_activities
  end

  it "should return all activities for two users (for admin)" do
    sc = SearchCriteria.new({ :user_id => [fx(:jola).id, fx(:stefan).id] }, fx(:admin))
    sc.should have(33).found_activities
  end

  it "should return all activities for specific client and role (for admin)" do
    sc = SearchCriteria.new({ :client_id => [fx(:banana).id], :role_id => [fx(:developer).id] }, fx(:admin))
    sc.should have(4).found_activities
  end

  it "should return all activities for specific project and user (for admin)" do
    sc = SearchCriteria.new({ :project_id => [fx(:banana).projects.active.first.id], :user_id => [fx(:stefan).id] }, fx(:admin))
    sc.should have(2).found_activities
    
    sc = SearchCriteria.new({ :project_id => [fx(:banana).projects.active.first.id], :user_id => [fx(:misio).id] }, fx(:admin))
    sc.should have(1).found_activities
  end


  # client
  
  it "should return all activities (for client)" do
    client_user = fx(:orange_user1)
    client = client_user.client
    sc = SearchCriteria.new({}, client_user)
    sc.should have(18).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
    
    client_user = fx(:apple_user1)
    client = client_user.client
    sc = SearchCriteria.new({}, client_user)
    sc.should have(18).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
    
    client_user = fx(:banana_user1)
    client = client_user.client
    sc = SearchCriteria.new({}, client_user)
    sc.should have(6).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for specific project (for client)" do
    client_user = fx(:orange_user1)
    client = client_user.client
    project = client.projects.active.first
    sc = SearchCriteria.new({ :project_id => [project.id] }, client_user)
    sc.should have(project.activities.count).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for two projects (for client)" do
    client_user = fx(:apple_user1)
    client = client_user.client
    projects = client.projects.active.all(:limit => 2)
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, client_user)
    sc.should have(projects[0].activities.count + projects[1].activities.count).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end
  
  it "should return all activities for specific role (for client)" do
    client_user = fx(:banana_user1)
    client = client_user.client
    sc = SearchCriteria.new({ :role_id => [fx(:developer).id] }, client_user)
    sc.should have(4).found_activities
    sc = SearchCriteria.new({ :role_id => [fx(:tester).id] }, client_user)
    sc.should have(2).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for specific user (for client)" do
    client_user = fx(:orange_user1)
    client = client_user.client
    sc = SearchCriteria.new({ :user_id => [fx(:jola).id] }, client_user)
    sc.should have(8).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for two users (for client)" do
    client_user = fx(:orange_user1)
    client = client_user.client
    sc = SearchCriteria.new({ :user_id => [fx(:jola).id, fx(:stefan).id] }, client_user)
    sc.should have(14).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end

  it "should return all activities for specific project and user (for client)" do
    client_user = fx(:apple_user1)
    client = client_user.client
    project = fx(:apples_first_project) #client.projects.active.first
    sc = SearchCriteria.new({ :project_id => [project.id], :user_id => [fx(:misio).id] }, client_user)
    sc.should have(2).found_activities
    sc = SearchCriteria.new({ :project_id => [project.id], :user_id => [fx(:stefan).id] }, client_user)
    sc.should have(3).found_activities
    sc.found_activities.each do |activity|
      activity.project.client_id.should == client.id
    end
  end
  
  it "shouldn't return any activities for other client's projects (for client)" do
    client_user = fx(:orange_user1)
    client = client_user.client
    other_client = fx(:apple)
    sc = SearchCriteria.new({ :client_id => [other_client.id] }, client_user)
    sc.found_activities.each do |activity|
      activity.project.client_id.should_not == other_client.id
    end
  end

  it "shouldn't return any activities for other client's project (for client)" do
    client_user = fx(:orange_user1)
    client = client_user.client
    project = client.projects.active.first
    other_client = fx(:apple)
    other_clients_project = other_client.projects.active.first
    sc = SearchCriteria.new({ :project_id => [other_clients_project.id] }, client_user)
    sc.found_activities.each do |activity|
      activity.project.client_id.should_not == other_client.id
    end
  end

  
  # employee
  
  it "should return all activities (for employee)" do
    user = fx(:jola)
    sc = SearchCriteria.new({}, user)
    sc.should have(19).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end

    user = fx(:misio)
    sc = SearchCriteria.new({}, user)
    sc.should have(9).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end

    user = fx(:stefan)
    sc = SearchCriteria.new({}, user)
    sc.should have(14).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "should return all activities for specific client (for employee)" do
    user = fx(:jola)
    sc = SearchCriteria.new({ :client_id => [fx(:orange).id] }, user)
    sc.should have(8).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "should return all activities for two clients (for employee)" do
    user = fx(:misio)
    clients = [fx(:orange), fx(:apple)]
    sc = SearchCriteria.new({ :client_id => [clients[0].id, clients[1].id] }, user)
    sc.should have(8).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end
  
  it "should return all activities for specific project (for employee)" do
    user = fx(:stefan)
    project = Project.active.first
    sc = SearchCriteria.new({ :project_id => [project.id] }, user)
    sc.should have(project.activities.count(:user_id => user.id)).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "should return all activities for two project of same client (for employee)" do
    user = fx(:jola)
    projects = Project.active.all(:limit => 2, :order => [:id])
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, user)
    sc.should have(projects[0].activities.count(:user_id => user.id) + 
                   projects[1].activities.count(:user_id => user.id)).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end
  
  it "should return all activities for two project of different clients (for employee)" do
    user = fx(:misio)
    clients = [fx(:orange), fx(:apple)]
    projects = [clients[0].projects.active.first, clients[1].projects.active.first]
    sc = SearchCriteria.new({ :project_id => [projects[0].id, projects[1].id] }, user)
    sc.should have(projects[0].activities.count(:user_id => user.id) + 
                   projects[1].activities.count(:user_id => user.id)).found_activities
    sc.found_activities.each do |activity|
      activity.user_id.should == user.id
    end
  end

  it "shouldn't return any activities for other user (for employee)" do
    user = fx(:stefan)
    other_user = fx(:jola)
    sc = SearchCriteria.new({ :user_id => [other_user.id] }, user)
    sc.found_activities.each do |activity|
      activity.user_id.should_not == other_user.id
    end
  end
end

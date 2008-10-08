require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Employee do
  before(:all) { User.all.destroy! }
  
  it "should create user" do
    lambda { Employee.make.save.should be_true }.should change(Employee, :count).by(1)
  end
  
  
  it "shouldn't be admin" do
    Employee.new.is_admin?.should be_false 
  end
  
  it "should validate user role" do
    user = Employee.make
    %w(kiszka stefan).each do |r|
      user.role = r
      user.save.should be_false
      user.errors.on(:role).should_not be_nil
    end

    User::ROLES.each do |r|
      user.role = r
      user.save.should be_true
    end
  end
  
  it "shouldn't create user without name" do
    user = Employee.gen :name => nil
    user.save.should be_false
    user.errors.on(:name).should_not be_nil
  end
  
  it "should be editable by himself and admin" do
    user = Employee.gen
    user.editable_by?(user).should be_true
    user.editable_by?(Admin.gen).should be_true
    user.editable_by?(User.gen).should be_false
  end
  
  it "should create user with given password and authenticate" do 
    pass = "kiszka123"
    login = "stefan13"
    
    user = Employee.make :login => login, :password => pass, :password_confirmation => pass
    user.save.should be_true
    User.authenticate(login, pass).should == User.get(user.id)
  end
  
  it "should be admin" do
    Employee.new(:admin => true).is_admin?.should be_true
  end
end

describe ClientUser do
  before(:all) { User.all.destroy!; Project.all.destroy! }
  
  it "shouldn't be admin" do
    ClientUser.new.is_admin?.should be_false 
  end
  
  it "should get list of its projects" do
    client = Client.gen
    project1 = Project.gen(:client => client)
    project1.client.should == client
    project2 = Project.gen(:client => client)
    project3 = Project.gen(:client => client)
    client.projects.size.should == 3
    client.projects.should include(project1)
    client.projects.should include(project2)
    client.projects.should include(project3)
  end
end

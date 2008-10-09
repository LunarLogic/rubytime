require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do
  it "should generate password" do
    user = User.new
    user.password.should be_nil
    user.password_confirmation.should be_nil
    user.generate_password!
    user.password.should_not be_nil
    user.password_confirmation.should_not be_nil
  end
  
  it "should check login format"
end

describe Employee do

  it "should create user" do
    lambda { Employee.make.save.should be_true }.should change(Employee, :count).by(1)
  end
  
  
  it "shouldn't be admin" do
    Employee.new.is_admin?.should be_false 
  end
  
  it "shouldn't create user without name" do
    user = Employee.gen :name => nil
    user.save.should be_false
    user.errors.on(:name).should_not be_nil
  end
  
  it "should be editable by himself and admin" do
    user = Employee.gen
    user.editable_by?(user).should be_true
    user.editable_by?(Employee.gen(:admin)).should be_true
    user.editable_by?(Employee.gen).should be_false
    user.editable_by?(ClientUser.gen).should be_false
  end
  
  it "should create user with given password and authenticate" do 
    pass = "kiszka123"
    login = "stefan13"
    
    user = Employee.make :login => login, :password => pass, :password_confirmation => pass
    user.save.should be_true
    User.authenticate(login, pass).should == User.get(user.id)
  end
  
  it "should be admin" do
    Employee.make(:admin).is_admin?.should be_true
  end
end

describe ClientUser do
  before(:all) { User.all.destroy!; Project.all.destroy! }
  
  it "shouldn't be admin" do
    ClientUser.new.is_admin?.should be_false 
  end
  
  it "should have client" do
    client_user = ClientUser.make(:client => nil)
    client_user.save.should be_false
    client_user.errors.on(:client).should_not be_nil
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

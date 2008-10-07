require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do
  before(:all) { User.all.destroy! }
  
  it "should create user" do
    before_save_count = User.count
    User.make.save.should be_true
    User.count.should be(before_save_count + 1)
  end
  
  
  it "shouldn't be admin" do
    User.new.is_admin?.should be_false 
  end
  
  it "shouldn't create user without name" do
    user = User.gen :name => nil
    user.save.should be_false
    user.errors.on(:name).should_not be_nil
  end
  
  it "should be editable by himself and admin" do
    user = User.gen
    user.editable_by?(user).should be_true
    user.editable_by?(Admin.gen).should be_true
    user.editable_by?(User.gen).should be_false
  end
  
  it "should create user with given password and authenticate" do 
    pass = "kiszka123"
    login = "stefan13"
    
    user = User.make :login => login, :password => pass, :password_confirmation => pass
    user.save.should be_true
    User.authenticate(login, pass).should == User.get(user.id)
  end
end

describe Client do
  before(:all) { User.all.destroy!; Project.all.destroy! }
  
  it "shouldn't be admin" do
    Client.new.is_admin?.should be_false 
  end
  
  it "should get list of its projects" do
    client = Client.gen
    project1 = Project.gen
    project1.client.should == client
    project2 = Project.gen
    project3 = Project.gen
    client.projects.size.should == 3
    client.projects.should include(project1)
    client.projects.should include(project2)
    client.projects.should include(project3)
  end
end

describe Admin do 
  it "should create default admin" do
    before_count = Admin.count
    admin = Admin.create_account
    admin.should be_true
    Admin.count.should == before_count + 1
  end
  
  it "should be admin" do
    Admin.new.is_admin?.should be_true
  end
end
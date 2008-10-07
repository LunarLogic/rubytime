require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  before(:all) { Client.all.destroy!; Project.all.destroy! }
  
  it "should create project" do
    before_save_count = Project.count
    Project.make.save.should be_true
    Project.count.should be(before_save_count + 1)
  end
  
  # it "should create user" do
  #   before_save_count = User.count
  #   User.make.save.should be_true
  #   User.count.should be(before_save_count + 1)
  # end
  
  
  # it "shouldn't be admin" do
  #   User.new.is_admin?.should be_false 
  # end
  
  # it "shouldn't create user without name" do
  #   user = User.gen :name => nil
  #   user.save.should be_false
  #   user.errors.on(:name).should_not be_nil
  # end
  
  # it "should be editable by himself and admin" do
  #   user = User.gen
  #   user.editable_by?(user).should be_true
  #   user.editable_by?(Admin.gen).should be_true
  #   user.editable_by?(User.gen).should be_false
  # end
  
  # it "should create user with given password and authenticate" do 
  #   pass = "kiszka123"
  #   login = "stefan13"
    
  #   user = User.make :login => login, :password => pass, :password_confirmation => pass
  #   user.save.should be_true
  #   User.authenticate(login, pass).should == User.get(user.id)
  # end
end

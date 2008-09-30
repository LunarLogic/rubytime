require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do

  it "should create user" do
    before_save_count = User.count
    user = User.gen
    user.save.should be_true
    User.count.should be(before_save_count + 1)
  end
  
  it "should be admin" do
    admin = Admin.gen
    admin.save.should be(true)
  end
  
  it "shouldn't be admin" do
    User.new.is_admin?.should be_false 
  end
  
  it "should be admin" do
    Admin.new.is_admin?.should be_true
  end
  
  it "shouldn't create user without name" do
    user = User.gen :name => nil
    user.save.should be_false
    user.errors.on(:name).should_not be_nil
  end
end

describe Admin do 
  it "should create default admin" do
    before_count = Admin.count
    admin = Admin.create_account
    admin.should be_true
    Admin.count.should == before_count + 1
  end
end
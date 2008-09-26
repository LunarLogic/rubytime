require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe User do

  it "should create user" do
    user = User.new
    user.save.should == true
  end

end
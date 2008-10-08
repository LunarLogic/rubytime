require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Users do
  include ControllerSpecsHelper
  
  before :all do 
    Admin.create_account if Admin.count == 0
  end
  
  before(:each) { Employee.gen if Employee.count == 0 }
  
  it "should redirect from new when user is not admin" do
    lambda { dispatch_to_as_employee(Users, :new) }.should raise_forbidden
  end

  it "Should render new" do
    User.should_receive(:new)
    controller = dispatch_to_as_admin(Users, :new)
    controller.should be_successful
  end
  
  it "should fetch all users" do
    User.should_receive(:all)
    dispatch_to_as_admin(Users, :index)
  end
  
  it "should render edit if user is admin" do
    user = User.first
    User.should_receive(:get).with(user.id.to_s).and_return(user)
    dispatch_to_as_admin(Users, :edit, { :id => user.id }).should be_successful
  end
  
  it "should raise forbidden from edit if user is not admin and trying to edit another user" do
    haxor = Employee.gen
    haxor.is_admin?.should be_false
    proc { dispatch_to_as(Users, :edit, haxor, { :id => haxor.another.id }) }.should raise_forbidden
  end
  
  it "update action should redirect to show" do
    user = User.first
    controller = dispatch_to_as_admin(Users, :update, { 
      :id => User.first.id, :user => { :name => "Jola", :role => "Tester" } })
    controller.should redirect_to(url(:user, user))
  end
  
  it "shouldn't allow User user to delete users" do
    haxor = Employee.first
    proc { dispatch_to_as(Users, :destroy, haxor, {}) }.should raise_forbidden
  end
  
  it "should render not found for nonexisting user id" do
    proc { dispatch_to_as_admin(Users, :show, { :id => 1234567 }) }.should raise_not_found
  end
  
end
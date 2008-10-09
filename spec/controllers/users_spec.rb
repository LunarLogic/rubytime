require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Users do
  include ControllerSpecsHelper

  before(:each) { prepare_users }
  
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
    User.should_receive(:get).with(@employee.id.to_s).and_return(@employee)
    dispatch_to_as_admin(Users, :edit, { :id => @employee.id }).should be_successful
  end
  
  it "should raise forbidden from edit if user is not admin and trying to edit another user" do
    haxor = Employee.gen
    haxor.is_admin?.should be_false
    proc { dispatch_to_as(Users, :edit, haxor, { :id => haxor.another.id }) }.should raise_forbidden
  end
  
  it "update action should redirect to show" do
    role = Role.gen
    controller = dispatch_to_as_admin(Users, :update, { 
      :id => @employee.id , :user => { :name => "Jola", :role_id => role.id } })
    controller.should redirect_to(url(:user, @employee))
    @employee.reload.role.should == role
  end
  
  it "shouldn't allow User user to delete users" do
    proc { dispatch_to_as_employee(Users, :destroy, { :id => @client }) }.should raise_forbidden
    proc { dispatch_to_as_client(Users, :destroy, { :id => @employee }) }.should raise_forbidden
  end
  
  it "should render not found for nonexisting user id" do
    proc { dispatch_to_as_admin(Users, :show, { :id => 1234567 }) }.should raise_not_found
  end  
end
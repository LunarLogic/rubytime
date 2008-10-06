require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Users do
  before :all do 
    Admin.create_account if Admin.count == 0
  end
  
  before(:each) { User.gen if User.count(:type.not => "Admin") == 0 }
  
  it "should redirect from new when user is not admin" do
    lambda { dispatch_to_as_user(Users, :new) }.should raise_forbidden
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
    haxor = User.gen
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
    haxor = User.not_admin.first
    proc { dispatch_to_as(Users, :destroy, haxor, {}) }.should raise_forbidden
  end
  
  it "should render not found for nonexisting user id" do
    proc { dispatch_to_as_admin(Users, :show, { :id => 1234567 }) }.should raise_not_found
  end
  
  private
  
  def dispatch_to_as_admin(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, Admin.first, params, &blk)
  end
  
  def dispatch_to_as_user(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, User.not_admin.first, params, &blk)
  end
  
  def dispatch_to_as(controller_klass, action, user, params = {}, &blk)
    dispatch_to(controller_klass, action, params) do |controller|
      controller.stub! :render
      controller.stub!(:current_user).and_return(user)
      blk.call(controller) if block_given?
      controller
    end
  end
  
  def raise_not_found
    raise_error Merb::Controller::NotFound
  end
  
  def raise_forbidden
    raise_error Merb::Controller::Forbidden
  end
end
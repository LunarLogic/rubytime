require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Users do
  
  before :all do 
    Admin.create_account if Admin.count == 0
    User.gen.save! if User.count(:type.not => "Admin") == 0
  end
  
  it "should redirect from new when user is not admin" do
    controller = dispatch_to_as_user(Users, :new)
    controller.should redirect_to(:controller => "Exceptions", :action => "forbidden")
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
  
  private
  
  def dispatch_to_as_admin(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, Admin.first, params, &blk)
  end
  
  def dispatch_to_as_user(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, User.first(:type.not => "Admin"), params, &blk)
  end
  
  def dispatch_to_as(controller_klass, action, user, params = {}, &blk)
    dispatch_to(controller_klass, action, params) do |controller|
      controller.stub! :render
      controller.stub!(:current_user).and_return(user)
      blk.call(controller) if block_given?
      controller
    end
  end
end
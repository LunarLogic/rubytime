require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Users do
  it "shouldn't show index for guest" do
    as(:guest).dispatch_to(Users, :index).should redirect_to(url(:login))
  end

  it "should redirect from new when user is not admin" do
    block_should(raise_forbidden) { as(:employee).dispatch_to(Users, :new) }
  end

  it "Should render new" do
    User.should_receive(:new)
    as(:admin).dispatch_to(Users, :new).should be_successful
  end
  
  it "should fetch all users" do
    User.should_receive(:all).and_return([Employee.gen, Employee.gen, ClientUser.gen])
    dispatch_to_as_admin(Users, :index)
  end
  
  it "should render edit if user is admin" do
    User.should_receive(:get).with(@employee.id.to_s).and_return(@employee)
    as(:admin).dispatch_to(Users, :edit, { :id => @employee.id }).should be_successful
  end
  
  it "should raise forbidden from edit if user is not admin and trying to edit another user" do
    haxor = Employee.gen
    haxor.is_admin?.should be_false
    
    block_should(raise_forbidden) do
      as(haxor).dispatch_to(Users, :edit, { :id => haxor.another.id })
    end
  end
  
  it "update action should redirect to show" do
    role = Role.gen
    controller = as(:admin).dispatch_to(Users, :update, { 
      :id => @employee.id , :user => { :name => "Jola", :role_id => role.id } })
    controller.should redirect_to(url(:user, @employee))
    @employee.reload.role.should == role
  end
  
  it "shouldn't allow User user to delete users" do
    block_should(raise_forbidden) do
      as(:employee).dispatch_to(Users, :destroy, { :id => @client })
    end
    block_should(raise_forbidden) do
      as(:client).dispatch_to(Users, :destroy, { :id => @employee })
    end
  end
  
  it "should render not found for nonexisting user id" do
    block_should(raise_not_found) do
      as(:admin).dispatch_to(Users, :show, { :id => 1234567 })
    end
  end  
  
  it "should not change password when posted blank" do
    previous_password = @employee.reload.password
    controller = as(:admin).dispatch_to(Users, :update, {
      :id => @employee.id,
      :user => { :password => "", :password_confirmation => "", :name => "stefan 123" } 
    })
    controller.should redirect_to(url(:user, @employee.id))
    previous_password.should == @employee.reload.password
  end
  
  it "should udpate active property" do
    @employee.active.should be_true
    controller = as(:admin).dispatch_to(Users, :update, { :id => @employee.id, :user => { :active => 0 } })
    controller.should redirect_to(url(:user, @employee.id))
    # controller.instance_variable_get(:@employee).dirty?.should 
    @employee.reload.active.should be_false
  end
  
  it "shouldn't allow user to update role" do
    admin    = Role.create! :name => "Adminz0r"
    dev      = Role.create! :name => "Devel0per"
    employee = Employee.gen(:role => dev)
    
    [admin, dev].each do |role|
      controller = as(employee.another).dispatch_to(Users, :update, { :id => employee.id, :user => { :role_id => role.id} })
      controller.should redirect_to(url(:user, employee.id))
      employee.reload.role.should == role
    end
  end

  it "shouldnt destroy user which has activities" do
    user = Employee.gen(:with_activities)
    block_should_not(change(User, :count)) do
      as(:admin).dispatch_to(Users, :destroy, { :id => user.id}).status.should == 400
    end
  end
  
  it "should allow admin to see users for specific role" do
    as(:admin).dispatch_to(Users, :with_roles, :search_criteria => {}).status.should == 200
  end
  
  it "should allow client to see users for specific role" do
    as(:client).dispatch_to(Users, :with_roles, :search_criteria => {}).status.should == 200
  end

  it "shouldn't allow employee to see users" do
    block_should(raise_forbidden) do
      as(:employee).dispatch_to(Users, :with_roles, :search_criteria => {})
    end
  end
end
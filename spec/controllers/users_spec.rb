require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Users do
  describe "#index" do
    it "shouldn't show index for guest" do
      block_should(raise_unauthenticated) do
        as(:guest).dispatch_to(Users, :index)
      end
    end

    it "should fetch all users" do
      User.should_receive(:all).and_return([fx(:jola), fx(:misio), fx(:orange_user1)])
      as(:admin).dispatch_to(Users, :index)
    end
  end
  
  describe "#edit" do
    it "should render edit if user is admin" do
      user = fx(:stefan)
      User.should_receive(:get).with(user.id.to_s).and_return(user)
      as(:admin).dispatch_to(Users, :edit, { :id => user.id }).should be_successful
    end
    
    it "should raise forbidden from edit if user is not admin and trying to edit another user" do
      haxor = fx(:misio)
      haxor.is_admin?.should be_false
      
      block_should(raise_forbidden) { as(haxor).dispatch_to(Users, :edit, { :id => haxor.another.id }) }
    end
  end

  describe "#show" do  
    it "should render not found for nonexisting user id" do
      block_should(raise_not_found) { as(:admin).dispatch_to(Users, :show, { :id => 1234567 }) }
    end

    it "should render user information for admin" do
      as(:admin).dispatch_to(Users, :show, { :id => fx(:jola).id }).should be_successful
    end
  end
  
  describe "#update" do
    it "update action should redirect to show" do
      user = fx(:misio)
      new_role = fx(:tester)
  
      block_should(change(user, :role_id)) do
        controller = as(:admin).dispatch_to(Users, :update, 
          { :id => user.id , :user => { :name => "Jola", :role_id => new_role.id } })
        controller.should redirect_to(url(:user, user))
        user.reload 
      end
    end
    
    it "should not change password when posted blank" do
      user = fx(:koza)
      block_should_not(change(user, :password)) do
        as(:admin).dispatch_to(Users, :update, {
          :id => user.id,
          :user => { :password => "", :password_confirmation => "", :name => "stefan 123" } 
        }).should redirect_to(url(:user, user))
        user.reload
      end    
    end
    
    it "should udpate active property" do
      user = fx(:misio)
      block_should(change(user, :active)) do
        controller = as(:admin).dispatch_to(Users, :update, { :id => user.id, :user => { :active => 0 } })
        controller.should redirect_to(url(:user, user))
        user.reload
      end
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
  end

  describe "#destroy" do
    it "shouldnt destroy user which has activities" do
      block_should_not(change(User, :count)) do
        as(:admin).dispatch_to(Users, :destroy, { :id => fx(:jola).id}).status.should == 400
      end
    end
  
    it "shouldn't allow User user to delete users" do
      block_should(raise_forbidden) { as(:employee).dispatch_to(Users, :destroy, { :id => @client }) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Users, :destroy, { :id => @employee }) }
    end
  end
  
  describe "#with_roles" do
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
end
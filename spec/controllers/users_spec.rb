require 'spec_helper'

describe Users do
  describe "#index" do
    it "shouldn't show index for guest" do
      block_should(raise_unauthenticated) do
        as(:guest).dispatch_to(Users, :index)
      end
    end

    it "should fetch all users" do
      users = (0..1).map { Employee.generate }
      User.should_receive(:all).and_return(users)
      as(:admin).dispatch_to(Users, :index)
    end
  end

  describe "#edit" do
    before :each do
      @user = Employee.generate
    end

    it "should render edit if user is admin" do
      User.should_receive(:get).with(@user.id.to_s).and_return(@user)
      as(:admin).dispatch_to(Users, :edit, :id => @user.id).should be_successful
    end

    it "should raise forbidden from edit if user is not admin and trying to edit another user" do
      block_should(raise_forbidden) { as(:employee).dispatch_to(Users, :edit, :id => @user.id) }
    end

    it "should raise forbidden from edit if user is not admin and trying to edit his own account" do
      # user should only have access to /settings page
      block_should(raise_forbidden) { as(@user).dispatch_to(Users, :edit, :id => @user.id) }
    end

    it "should raise forbidden for client users" do
      block_should(raise_forbidden) { as(:client).dispatch_to(Users, :edit, :id => @user.id) }
    end
  end

  describe "#show" do  
    before :each do
      @user = Employee.generate
    end

    it "should render not found for nonexisting user id" do
      block_should(raise_not_found) { as(:admin).dispatch_to(Users, :show, :id => 1234567) }
    end

    it "should render user information for admin" do
      as(:admin).dispatch_to(Users, :show, :id => @user.id).should be_successful
    end

    it "should raise forbidden for non-admin users" do
      block_should(raise_forbidden) { as(:employee).dispatch_to(Users, :show, :id => @user.id) }
    end

    it "should raise forbidden for client users" do
      block_should(raise_forbidden) { as(:client).dispatch_to(Users, :show, :id => @user.id) }
    end
  end

  describe "#update" do
    it "update action should redirect to show" do
      user = Employee.generate
      new_role = Role.generate
  
      block_should(change(user, :role_id)) do
        response = as(:admin).dispatch_to(Users, :update, {
          :id => user.id,
          :user => {
            :name => "Jola",
            :role_id => new_role.id
          }
        })
        response.should redirect_to(url(:user, user))
        user.reload
      end
    end

    it "should not change password when posted blank" do
      user = Employee.generate
      block_should_not(change(user, :password)) do
        as(:admin).dispatch_to(Users, :update, {
          :id => user.id,
          :user => {
            :password => "",
            :password_confirmation => "",
            :name => "stefan 123"
          }
        }).should redirect_to(url(:user, user))
        user.reload
      end    
    end

    it "should udpate active property" do
      user = Employee.generate
      block_should(change(user, :active)) do
        response = as(:admin).dispatch_to(Users, :update, :id => user.id, :user => { :active => 0 })
        response.should redirect_to(url(:user, user))
        user.reload
      end
    end

    it "shouldn't allow client user to change his client" do
      apple = Client.generate
      microsoft = Client.generate
      steveb = ClientUser.generate :client => microsoft

      response = as(steveb).dispatch_to(Users, :update, :id => steveb.id, :user => {
        :client_id => apple.id,
      })
      response.should redirect_to(url(:activities))

      steveb.reload
      steveb.client.should == microsoft
    end

    it "shouldn't allow user to update his role, type, admin rights, login or active state" do
      devs = Role.generate
      admins = Role.generate
      user = Employee.generate :role => devs, :login => 'oldlogin', :active => true

      response = as(user).dispatch_to(Users, :update, {
        :id => user.id,
        :user => {
          :role_id => admins.id,
          :login => 'newlogin',
          :active => false,
          :type => 'ClientUser',
          :admin => true
        }
      })
      response.should redirect_to(url(:activities))

      user.reload
      user.role.should == devs
      user.login.should == 'oldlogin'
      user.should be_active
      user.should be_an_instance_of(Employee)
      user.type.should == Employee
      user.should_not be_admin
    end

    it "shouldn't allow user to update other users" do
      user = Employee.generate

      block_should(raise_forbidden) do
        as(:employee).dispatch_to(Users, :update, :id => user.id, :user => { :name => 'Bob' })
      end

      user.reload
      user.name.should_not == "Bob"
    end
    
    it "should allow admin to change client user into employee user" do
       user = ClientUser.generate
       block_should(change(user, :type)) do
         response = as(:admin).dispatch_to(Users, :update, :id => user.id, :user => { :class_name => 'Employee', :role_id => Role.generate.id })
         response.should redirect_to(url(:user, user))
         user.reload
       end
       user.reload
       user.type.should == Employee
       user.role.should_not be_nil
       user.client.should be_nil
    end
  end

  describe "#destroy" do
    before :each do
      @user = Employee.generate
    end

    it "shouldnt destroy user which has activities" do
      Activity.generate :user => @user
      admin = Employee.generate :admin
      block_should_not(change(User, :count)) do
        as(admin).dispatch_to(Users, :destroy, :id => @user.id).status.should == 400
      end
    end

    it "shouldn't allow user to delete other users" do
      block_should(raise_forbidden) { as(:employee).dispatch_to(Users, :destroy, :id => @user) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Users, :destroy, :id => @user) }
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

  describe "#with_activities" do
    it "should list all users with activities for Admin" do
      Employee.should_receive(:with_activities)
      as(:admin).dispatch_to(Users, :with_activities)
    end

    it "should list all users with activities in any of the client's projects for ClientUser" do
<<<<<<< HEAD
      client_user = ClientUser.generate
      Employee.should_receive(:with_activities_for_client).with(client_user.client)
=======
      client = fx(:orange)
      client_user = client.client_users.first
      Employee.should_receive(:with_activities_for_client).with(client)
>>>>>>> origin/3.2
      as(client_user).dispatch_to(Users, :with_activities)
    end

    it "shouldn't allow employee to see user list" do
      block_should(raise_forbidden) do
        as(:employee).dispatch_to(Users, :with_activities)
      end
    end
  end

  describe "#authenticate" do
    it "should return user data as json, if login data is correct" do
<<<<<<< HEAD
      employee = Employee.generate
      response = as(employee).dispatch_to(Users, :authenticate)
      response.should be_successful
      JSON::parse(response.body)["login"].should == employee.login
=======
      employee = fx(:apple_user1)
      response = as(employee).dispatch_to(Users, :authenticate)
      response.should be_successful
      response.body.should =~ /"login": "#{employee.login}"/
>>>>>>> origin/3.2
    end

    it "should include user_type field" do
      response = as(:employee).dispatch_to(Users, :authenticate)
<<<<<<< HEAD
      JSON::parse(response.body)["user_type"].should == "employee"
=======
      response.body.should =~ /"user_type": "employee"/
>>>>>>> origin/3.2
    end

    it "should block unauthenticated users" do
      block_should(raise_unauthenticated) do
        as(:guest).dispatch_to(Users, :authenticate)
      end
    end
  end

  describe "#reset_password" do
    before :all do
      @user = Employee.generate
      @user.generate_password_reset_token
    end

    it "should raise bad request if there is no token" do
      block_should(raise_bad_request) { dispatch_to(Users, :reset_password) }
    end

    it "should raise error if token is incorrect" do
      block_should(raise_not_found) { dispatch_to(Users, :reset_password, :token => 'i_can_has_password?') }
    end

    it "should redirect to settings page" do
      response = dispatch_to(Users, :reset_password, :token => @user.password_reset_token)
      response.should redirect_to(url(:settings_user, @user.id))
    end

    it 'should redirect to password_reset if a token has expired' do
      @user.update :password_reset_token_exp => (DateTime.now - 1.hour)
      response = dispatch_to(Users, :reset_password, :token => @user.password_reset_token)
      response.should redirect_to(resource(:users, :request_password))
    end
  end

end

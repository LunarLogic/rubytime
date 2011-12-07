require 'spec_helper'

describe UsersController do
  describe "GET 'index'" do
    context "as guest" do
      login(:guest)

      it { get(:index).should redirect_to(new_user_session_path) }
    end

    context "as admin" do
      login(:admin)
      
      it "should fetch all users" do
        users = (0..1).map { Employee.generate }
        User.should_receive(:all).and_return(users)
        get(:index)
      end
    end
  end

  describe "GET 'edit'" do
    before :each do
      @user = Employee.generate
    end

    context "as admin" do
      login(:admin)

      it "should render edit if user is admin" do
        get(:edit, :id => @user.id.to_s).should be_successful
        assigns[:user].should == @user
      end
    end

    context "as self" do
      before(:each) do
        login(@user)
      end  
    
      it "should raise forbidden from edit if user is not admin and trying to edit another user" do
        get(:edit, :id => User.generate.id).status.should == 403
      end

      it "should raise forbidden from edit if user is not admin and trying to edit his own account" do
        # user should only have access to /settings page
        get(:edit, :id => @user.id).status.should == 403
      end
    end
      
    context "as client" do
      login(:client)
      
      it { get(:edit, :id => @user.id).status.should == 403 }
    end
  end

  describe "GET 'show'" do  
    before :each do
      @user = Employee.generate
    end

    context "as admin" do
      login(:admin)

      it { get(:show, :id => @user.id).should be_successful }
      
      it "should render not found for nonexisting user id" do
        expect { get(:show, :id => 1234567) }.to raise_error(DataMapper::ObjectNotFoundError)
      end
    end

    context "as non-admin" do      
      it "should raise forbidden" do
        for user in [:client, :employee]
          login(user)
          get(:show, :id => @user.id).status.should == 403
        end
      end
    end
  end

  describe "PUT 'update'" do
    context "as admin" do
      let(:user) { Employee.generate }
      login(:admin)

      it "update action should redirect to show" do
        new_role = Role.generate
        
        block_should(change(user, :role_id)) do
          put(:update, {:id => user.id, :user => {
                  :name => "Jola", :role_id => new_role.id}})
          response.should redirect_to(user_path(user))
          user.reload
        end
      end

      it "should not change password when posted blank" do
        block_should_not(change(user, :password)) do
          put(:update, {:id => user.id, :user => {
              :password => "", :password_confirmation => "", :name => "stefan 123"}})
          response.should redirect_to(user_path(user))
          user.reload
        end    
      end

      it "should update active property" do
        block_should(change(user, :active)) do
          put(:update, :id => user.id, :user => { :active => 0 })
          response.should redirect_to(user_path(user))
          user.reload
        end
      end

      it "should allow admin to change client user into employee user" do
        user = ClientUser.generate
        block_should(change(user, :type)) do
          put(:update, :id => user.id, :user => 
              { :class_name => 'Employee', :role_id => Role.generate.id })
          response.should redirect_to(user_path(user))
          user.reload
        end
        user.reload
        user.type.should == Employee
        user.role.should_not be_nil
        user.client.should be_nil
      end
    end

    context "as client" do
      it "shouldn't allow client user to change his client" do
        apple = Client.generate
        microsoft = Client.generate
        steveb = ClientUser.generate :client => microsoft
        login(steveb)

        put(:update, :id => steveb.id, :user => {:client_id => apple.id,})

        response.should redirect_to(activities_path)
        steveb.reload.client.should == microsoft
      end
    end

    context "as employee" do
      it "shouldn't allow user to update his role, type, admin rights, login or active state" do
        devs = Role.generate
        admins = Role.generate
        user = Employee.generate :role => devs, :login => 'oldlogin', :active => true
        login(user)

        put(:update, {
              :id => user.id,
              :user => {
                :role_id => admins.id,
                :login => 'newlogin',
                :active => false,
                :type => 'ClientUser',
                :admin => true
              }
            })
        response.should redirect_to(activities_path)

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
        login(:employee)
        
        put(:update, :id => user.id, :user => { :name => 'Bob' }).status.should == 403
        user.reload.name.should_not == "Bob"
      end
    end    
  end

  describe "DELETE 'destroy'" do
    let(:user) { Employee.generate }

    context "as admin" do
      login(:admin)

      it "shouldn't destroy user which has activities" do
        Activity.generate :user => user
        block_should_not(change(User, :count)) do
          delete(:destroy, :id => user.id).status.should == 400
        end
      end
    end

    context "as non-admin" do
      it "shouldn't allow user to delete other users" do
        for user_type in [:employee, :client]
          login(user_type)
          delete(:destroy, :id => user.id).status.should == 403
        end
      end
    end
  end

  describe "GET 'with_roles'" do
    context "as admin" do
      login(:admin)

      it { get(:with_roles, :search_criteria => {}).should be_successful }
    end

    context "as client" do
      login(:client)

      it { get(:with_roles, :search_criteria => {}).should be_successful }
    end

    context "as employee" do
      login(:employee)
      
      it { get(:with_roles, :search_criteria => {}).status.should == 403 }
    end
  end

  describe "GET 'with_activities'" do
    context "as admin" do
      login(:admin)
      
      it "should list all users with activities for Admin" do
        Employee.should_receive(:with_activities)
        get(:with_activities)
      end
    end

    context "as client" do
      login(:client)

      it "should list all users with activities in any of the client's projects for ClientUser" do
        Employee.should_receive(:with_activities_for_client).with(@current_user.client)
        get(:with_activities)
      end
    end

    context "as employee" do
      login(:employee)

      it { get(:with_activities).status.should == 403 }
    end
  end

  describe "GET 'authenticate'" do
    context "as employee" do
      login(:employee)

      it "should return user data as json, if login data is correct" do
        get(:authenticate).should be_successful
        JSON::parse(response.body)["login"].should == @current_user.login
      end

      it "should include user_type field" do
        get(:authenticate)
        JSON::parse(response.body)["user_type"].should == "employee"
      end
    end

    context "as guest" do
      login(:guest)
      
      it { get(:authenticate).should redirect_to(new_user_session_path) }
    end
  end
end

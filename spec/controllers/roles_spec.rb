require 'spec_helper'

describe RolesController do
  context "as guest" do
    login(:guest)
    
    it "should ask to login on any action" do
      get(:index).                               should redirect_to(new_user_session_path)
      post(:create).                             should redirect_to(new_user_session_path)
      get(:edit, :id => 1).                      should redirect_to(new_user_session_path)
      put(:update, :id => 1).                    should redirect_to(new_user_session_path)
      delete(:destroy, :id => 1).                should redirect_to(new_user_session_path)
    end
  end

  context "as non-admin user" do
    it "should forbid all actions" do
      [:employee, :client].each do |user|
        login(user)

        get(:index).                               status.should == 403
        post(:create).                             status.should == 403
        get(:edit, :id => 1).                      status.should == 403
        put(:update, :id => 1).                    status.should == 403
        delete(:destroy, :id => 1).                status.should == 403
      end
    end
  end

  describe "GET 'index'" do
    login(:admin)

    it { get(:index).should be_successful }
  end

  describe "POST 'create'" do
    login(:admin)
    
    it "should create new role successfully and redirect to index" do
      block_should(change(Role, :count)) do
        post(:create, { :role => { :name => "Mastah" }})
        response.should redirect_to(roles_path)
      end
    end
  end

  describe "GET 'edit'" do
    login(:admin)

    it "should show role edit form" do
      role = Role.generate
      get(:edit, :id => role.id).should be_successful
    end
  end

  describe "PUT 'update'" do
    login(:admin)

    it "should update the role" do
      role = Role.generate
      put(:update, :id => role.id, :role => {
        :can_manage_financial_data => true
      })

      response.should redirect_to(roles_path)
      role.reload.can_manage_financial_data.should be_true
    end
  end

  describe "DELETE 'destroy'" do
    login(:admin)
    it "should delete role" do
      role = Role.generate

      block_should(change(Role, :count).by(-1)) do
        delete(:destroy, :id => role.id)
      end
    end
  end

end

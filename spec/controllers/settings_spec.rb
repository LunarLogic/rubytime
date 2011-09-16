require 'spec_helper'

describe SettingsController do

  context "as guest" do
    login(:guest)
    
    it "should ask to login on any action" do
      get(:edit, :id => 1).   should redirect_to(new_user_session_path)
      put(:update, :id => 1). should redirect_to(new_user_session_path)
    end
  end

  context "as non-admin user" do
    it "should forbid all actions" do
      [:employee, :client].each do |user|
        login(user)

        get(:edit, :id => 1).   status.should == 403
        put(:update, :id => 1). status.should == 403
      end
    end
  end

  describe "GET 'edit'" do
    login(:admin)

    it { get(:edit).should be_successful }
  end

  describe "PUT" do
    login(:admin)

    it "should update the setting record" do
      Setting.get.update :enable_notifications => true
      Setting.enable_notifications.should be_true
      put(:update, :setting => { :enable_notifications => false })
      response.should redirect_to(edit_settings_path)
      Setting.enable_notifications.should be_false
    end
  end

end

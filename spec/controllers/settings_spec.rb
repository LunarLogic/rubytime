require 'spec_helper'

describe SettingsController do

  it "shouldn't show any action for guest, employee and client's user" do
    [:edit, :update].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(Settings, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(Settings, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Settings, action) }
    end
  end

  describe "GET" do
    it "responds successfully" do
      as(:admin).dispatch_to(Settings, :edit).should be_successful
    end
  end

  describe "PUT" do
    it "should update the setting record" do
      Setting.get.update :enable_notifications => true
      Setting.enable_notifications.should be_true
      response = as(:admin).dispatch_to(Settings, :update, :setting => { :enable_notifications => false })
      response.should redirect_to(url(:edit_settings))
      Setting.enable_notifications.should be_false
    end
  end

end

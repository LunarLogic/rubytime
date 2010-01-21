require 'spec_helper'

describe Settings do
  
  it "shouldn't show any action for guest, employee and client's user" do
    [:edit, :update].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(Settings, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(Settings, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Settings, action) }
    end
  end
  
  describe "GET" do
    before(:each) do
      @response = as(:admin).dispatch_to(Settings, :edit)
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @response = as(:admin).dispatch_to(Settings, :update, :setting => {:enable_notifications => false})      
    end
  
    it "redirect to the setting edit action" do
      @response.should redirect_to(url(:edit_settings))
    end
    
    it "should update the setting record" do
      Setting.enable_notifications.should == false
    end
  end
  
end


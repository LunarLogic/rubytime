require 'spec_helper'

describe "Login" do

  context "user" do
    before :each do
      @user = Employee.generate      
    end

    it "should be able to login" do
      post user_session_path("user[email]" =>  @user.email,
                             "user[password]" => Factory.attributes_for(:user)[:password])
      response.should be_redirect
    end
  end

  context "inactive user" do
    before :each do
      @user = Employee.generate(:active => false)
    end

    it "should not be able to login" do
      post user_session_path("user[email]" => @user.email,
                             "user[password]" => Factory.attributes_for(:user)[:password])
      response.should be_successful
    end
  end
end

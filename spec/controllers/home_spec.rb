require 'spec_helper'

describe HomeController do
  context "when user is logged in" do
    login :employee
    
    it "should redirect to activities list" do
      get :index
      response.should redirect_to(activities_path)
    end
  end

  context "when admin is logged in" do
    login :admin

    it "should redirect to activities list" do
      get :index
      response.should redirect_to(activities_path)
    end
  end

  context "when client is logged in" do
    login :client

    it "should redirect to activities list" do
      get :index
      response.should redirect_to(activities_path)
    end
  end

  context "when no one is logged in" do
    login :guest

    it "should redirect to login page" do
      get :index
      response.should redirect_to(new_user_session_path)
    end
  end
end

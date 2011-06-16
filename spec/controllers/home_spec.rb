require 'spec_helper'

describe Home do
  context "when user is logged in" do
    it "should redirect to activities list" do
      response = as(:employee).dispatch_to(Home, :index)
      response.should redirect_to(resource(:activities))
    end
  end

  context "when admin is logged in" do
    it "should redirect to activities list" do
      response = as(:admin).dispatch_to(Home, :index)
      response.should redirect_to(resource(:activities))
    end
  end

  context "when client is logged in" do
    it "should redirect to activities list" do
      response = as(:client).dispatch_to(Home, :index)
      response.should redirect_to(resource(:activities))
    end
  end

  context "when no one is logged in" do
    it "should redirect to login page" do
      response = as(:guest).dispatch_to(Home, :index)
      response.should redirect_to(url(:login))
    end
  end
end

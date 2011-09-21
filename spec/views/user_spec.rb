require 'spec_helper'

describe "users/index.html.erb" do
  pending
end

describe "users/show.html.erb" do
  pending
end

describe "users/edit.html.erb" do
  pending
end

describe "users/request_password.html.erb" do
  pending
end

describe "users/settings.html.erb" do
  context "as employee" do
    before(:each) do
      login(:employee)
      @user = @current_user
    end

    it "should render successfully" do
      render
    end
  end

  context "as admin" do
    pending
  end
end

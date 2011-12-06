require 'spec_helper'

describe "users/index.html.erb" do
  before(:each) do
    @user = Employee.prepare
    @users = [Employee.generate]
    @roles = [Role.generate]
    @clients = [Client.generate]
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "users/show.html.erb" do
  before(:each) do
    @user = Employee.generate
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "users/edit.html.erb" do
  before(:each) do
    @user = Employee.generate
    @roles = [Role.generate]
    @clients = [Client.generate]
    login(:admin)
  end

  it "should render successfully" do
    render
  end
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
end

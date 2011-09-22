require 'spec_helper'

describe "clients/index.html.erb" do
  before(:each) do
    @client = Client.prepare
    @clients = [Client.generate]
    @client_user = ClientUser.prepare
  end

  it "should render successfully" do
    render
  end
end

describe "clients/show.html.erb" do
  before(:each) do
    @client = Client.generate
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "clients/edit.html.erb" do
  before(:each) do
    @client = Client.generate
  end

  it "should render successfully" do
    render
  end
end

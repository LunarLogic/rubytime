require 'spec_helper'

describe "projects/index.html.erb" do
  before(:each) do
    @project = Project.prepare
    @projects = [Project.generate]
    @clients = [Client.generate]
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "projects/show.html.erb" do
  before(:each) do
    @project = Project.generate
    @project.activity_types << ActivityType.generate
    @project.save
    @activities_without_types = [Activity.generate]
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "projects/edit.html.erb" do
  before(:each) do
    @project = Project.generate
    @clients = [Client.generate]
  end

  it "should render successfully" do
    render
  end
end

require 'spec_helper'

describe "activity_types/index.html.erb" do
  login(:admin)
  before(:each) do
    @new_activity_type = ActivityType.prepare
    @activity_types = [ActivityType.generate]
  end

  it "should render successfully" do
    render
  end
end

describe "activity_types/show.html.erb" do
  login(:admin)
  before(:each) do
    @activity_type = ActivityType.generate
    @child = ActivityType.generate(:parent_id => @activity_type.id)
    @new_activity_type = ActivityType.prepare(:parent_id => @activity_type.id)
  end

  it "should render successfully" do
    render
  end
end

describe "activity_types/edit.html.erb" do
  before(:each) do
    @activity_type = ActivityType.generate
    @old_name = "Some name"
  end

  it "should render successfully" do
    render
  end
end

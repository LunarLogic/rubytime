require 'spec_helper'

describe "activity_custom_properties/index.html.erb" do
  login(:admin)
  before(:each) do
    @new_activity_custom_property = ActivityCustomProperty.prepare
    @activity_custom_properties = [ActivityCustomProperty.generate]
  end

  it "should render successfully" do
    render
  end
end

describe "activity_custom_properties/edit.html.erb" do
  before(:each) do
    @activity_custom_property = ActivityCustomProperty.generate
  end

  it "should render successfully" do
    render
  end
end

require 'spec_helper'

describe "activities/index.html.erb" do
  before(:each) do
    login(:employee)
    @search_criteria = SearchCriteria.new({:date_from => DateTime.now}, @current_user)
    @activities = @search_criteria.found_activities
  end

  it "should render successfully" do
    render
  end
end

describe "activities/new.html.erb" do
  before(:each) do
    @activity = Activity.prepare
    @recent_projects = [Project.generate]
    @other_projects = [Project.generate]
    @activity_custom_properties = [ActivityCustomProperty.generate]
    login(:employee)
  end

  it "should render successfully" do
    render
  end
end

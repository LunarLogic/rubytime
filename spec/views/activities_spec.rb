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

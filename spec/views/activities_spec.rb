require 'spec_helper'

describe "activities/index.html.erb" do
  before(:each) do
    @activities = [Activity.generate]
    @custom_properties = [ActivityCustomProperty.generate]
    @column_properties = []
    @non_column_properties = []
  end

  context "as employee" do
    before(:each) do
      login(:employee)
      @search_criteria = SearchCriteria.new({:date_from => DateTime.now}, @current_user)      
    end

    it "should render successfully" do
      render
    end
  end

  context "as admin" do
    before(:each) do
      login(:admin)
      @search_criteria = SearchCriteria.new({:date_from => DateTime.now}, @current_user)
      @uninvoiced_activities = [Activity.generate]
      @invoice = Invoice.prepare
   end

    it "should render successfully" do
      render
    end
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

describe "activities/edit.html.erb" do
  before(:each) do
    @activity = Activity.generate
    @recent_projects = [Project.generate]
    @other_projects = [Project.generate]
    @activity_custom_properties = [ActivityCustomProperty.generate]
    login(:employee)
  end

  it "should render successfully" do
    render
  end
end

describe "activities/day.html.erb" do
  before(:each) do
    params[:search_criteria] = {:date_from => Date.today.to_s, :date_to => Date.today.to_s}
    @activities = [Activity.generate]
    @day = Date.today
    @custom_properties = [ActivityCustomProperty.generate]
    @column_properties = []
    @non_column_properties = []
    login(:employee)
  end

  it "should render successfully" do
    render
  end
end

describe "activities/calendar.html.erb" do
  before(:each) do
    @owner = Employee.generate
    Activity.generate(:user => @owner)
    @year = 2011
    @month = 9    
    @activities_by_date = @owner.activities.group_by(&:date)
  end

  context "as employee" do
    login(:employee)

    it "should render successfully" do
      render
    end
  end

  context "as admin" do
    login(:admin)

    it "should successfully render a calendar for users" do
      @users = [User.generate]
      render
    end

    it "should successfully render a calendar for projects" do
      @projects = [Project.generate]
      render
    end
  end
end

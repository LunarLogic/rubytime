require 'spec_helper'

describe "layouts/application.html.erb" do
  before(:each) do
    login(:employee)
    @number_of_columns = 1
  end

  it "should render successfully" do
    render
  end
end

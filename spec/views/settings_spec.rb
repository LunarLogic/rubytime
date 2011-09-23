require 'spec_helper'

describe "settings/edit.html.erb" do
  before(:each) do
    @setting = Setting.get
  end

  it "should render successfully" do
    render
  end
end

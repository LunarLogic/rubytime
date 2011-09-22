require 'spec_helper'

describe "roles/index.html.erb" do
  before(:each) do
    @role = Role.prepare
    @roles = [Role.generate]
  end

  it "should render successfully" do
    render
  end
end

describe "roles/edit.html.erb" do
  before(:each) do
    @role = Role.generate
  end

  it "should render successfully" do
    render
  end
end

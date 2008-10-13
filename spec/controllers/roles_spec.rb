require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Roles, "index action" do
  before(:each) do
    dispatch_to(Roles, :index)
  end
end
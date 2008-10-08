require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Projects, "index action" do
  before(:each) do
    dispatch_to(Projects, :index)
  end
end
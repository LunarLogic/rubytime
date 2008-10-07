require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Activities, "index action" do
  before(:each) do
    dispatch_to(Activities, :index)
  end
end
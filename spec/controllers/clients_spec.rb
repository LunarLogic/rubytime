require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Clients, "index action" do
  before(:each) do
    dispatch_to(Clients, :index)
  end
end
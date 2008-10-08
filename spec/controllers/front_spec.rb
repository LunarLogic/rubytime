require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Front, "index action" do
  before(:each) do
    dispatch_to(Front, :index)
  end
end
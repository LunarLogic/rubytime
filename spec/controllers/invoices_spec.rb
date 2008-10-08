require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Invoices, "index action" do
  before(:each) do
    dispatch_to(Invoices, :index)
  end
end
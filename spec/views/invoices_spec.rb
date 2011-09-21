require 'spec_helper'

describe "invoices/index.html.erb" do
  before(:each) do
    @invoices = [Invoice.generate]
    @invoice = Invoice.prepare
    @clients = [Client.generate]
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "invoices/show.html.erb" do
  before(:each) do
    @invoice = Invoice.generate
    @activities = [Activity.generate]
    login(:admin)
  end

  it "should render successfully" do
    render
  end
end

describe "invoices/edit.html.erb" do
  before(:each) do
    @invoice = Invoice.generate
    @clients = [Client.generate]
    login(:admin)
  end
  
  it "should render successfully" do
    render
  end
end

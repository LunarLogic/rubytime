require 'spec_helper'

describe "currencies/index.html.erb" do
  login(:admin)
  before(:each) do
    @currency = Currency.prepare
    @currencies = [Currency.generate]
  end

  it "should render successfully" do
    render
  end
end

describe "currencies/edit.html.erb" do
  before(:each) do
    @currency = Currency.generate
  end

  it "should render successfully" do
    render
  end
end

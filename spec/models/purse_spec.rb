require 'spec_helper'

describe Purse do

  before :each do
    @purse = Purse.new
  end

  before :all do
    @euro = Currency.first_or_generate :singular_name => 'euro'
    @dollar = Currency.first_or_generate :singular_name => 'dollar'
  end

  context "after initialize" do
    it "should be empty" do
      @purse.currencies.should == []
    end
  end

  it "should allow to put money inside and show content" do
    @purse.currencies.should == []
    @purse[@euro].should == Money.new(0.00, @euro)
    @purse[@dollar].should == Money.new(0.00, @dollar)

    @purse << Money.new(11.25, @euro)

    @purse.currencies.should == [@euro]
    @purse[@euro].should == Money.new(11.25, @euro)
    @purse[@dollar].should == Money.new(0.00, @dollar)

    @purse << Money.new(2.50, @euro)
    @purse << Money.new(9.98, @dollar)

    @purse.currencies.should == [@dollar, @euro]
    @purse[@euro].should == Money.new(13.75, @euro)
    @purse[@dollar].should == Money.new(9.98, @dollar)
  end

  it "should merge two purses together" do
    zl = Currency.first_or_generate(:singular_name => 'zloty')
    pound = Currency.first_or_generate(:singular_name => 'pound')

    @purse << Money.new(15, @euro)
    @purse << Money.new(3, zl)
    @purse << Money.new(14, pound)

    other = Purse.new
    other << Money.new(5, @euro)
    other << Money.new(10, @dollar)
    other << Money.new(20, zl)

    @purse.merge(other)
    @purse.currencies.should == [@dollar, @euro, pound, zl]
    @purse[@dollar].should == Money.new(10, @dollar)
    @purse[@euro].should == Money.new(20, @euro)
    @purse[pound].should == Money.new(14, pound)
    @purse[zl].should == Money.new(23, zl)

    # other should remain unchanged
    other.currencies.should == [@dollar, @euro, zl]
    other[@euro].should == Money.new(5, @euro)
    other[@dollar].should == Money.new(10, @dollar)
    other[zl].should == Money.new(20, zl)
  end

  describe "#to_s" do
    it "should return content as string" do
      @purse << Money.new(2.50, @euro)
      @purse << Money.new(9.98, @dollar)

      @purse.to_s.should == Money.new(9.98, @dollar).to_s + ' and ' + Money.new(2.50, @euro).to_s
    end
  end

end

require 'spec_helper'

describe Purse do
  
  before { @purse = Purse.new }
  
  context "after initialize" do
    it "should be empty" do
      @purse.currencies.should == []
    end
  end
  
  it "should allow to put money inside and show content" do
    @purse.currencies.should == []
    @purse[fx(:euro)  ].should == Money.new(0.00, fx(:euro))
    @purse[fx(:dollar)].should == Money.new(0.00, fx(:dollar))
    
    
    @purse << Money.new(11.25, fx(:euro))
    
    @purse.currencies.should == [ fx(:euro) ]
    @purse[fx(:euro)  ].should == Money.new(11.25, fx(:euro))
    @purse[fx(:dollar)].should == Money.new( 0.00, fx(:dollar))
    
    
    @purse << Money.new(2.50, fx(:euro))
    @purse << Money.new(9.98, fx(:dollar))
    
    @purse.currencies.should == [ fx(:dollar), fx(:euro) ]
    @purse[fx(:euro)  ].should == Money.new(13.75, fx(:euro))
    @purse[fx(:dollar)].should == Money.new( 9.98, fx(:dollar))
  end
  
  describe "#to_s" do
    it "should return content as string" do
      @purse << Money.new(2.50, fx(:euro))
      @purse << Money.new(9.98, fx(:dollar))
      
      @purse.to_s.should == Money.new(9.98, fx(:dollar)).to_s + ' and ' + Money.new(2.50, fx(:euro)).to_s
    end
  end
end

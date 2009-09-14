require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Duration do
  
  it "should be summable" do
    ( Duration.new(10.minutes) + Duration.new(5.minutes) ).should == Duration.new(15.minutes)
    ( Duration.new(10.minutes) + 3.minutes ).should == Duration.new(13.minutes)
    ( 15.minutes + Duration.new(10.minutes) ).should == Duration.new(25.minutes)
  end
  
  it "should be comparable with Fixnums" do
    ( Duration.new(10.minutes) == 10.minutes ).should be_true
    ( Duration.new(10.minutes)  > 15.minutes ).should be_false
  end
  
  describe "#to_s" do
    context "if called without arguments" do
      
      it "should return string with formatted hours and minutes" do
        Duration.new(            10.minutes ).to_s.should ==  "0:10"
        Duration.new(  3.hours + 25.minutes ).to_s.should ==  "3:25"
        Duration.new( 36.hours              ).to_s.should == "36:00"
      end
    end
  end
end

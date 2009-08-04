require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Date, '#weekend?' do
  
  it 'should return true for for weekend dates' do
    Date.parse('Saturday 2009-08-01').weekend?.should be_true
  end
  
  it 'should return false for for weekday dates' do
    Date.parse('Monday 2009-08-03').weekend?.should be_false
  end
  
end

describe Date, '#weekday?' do
  
  it 'should return true for for weekday dates' do
    Date.parse('Monday 2009-08-03').weekday?.should be_true
  end
  
  it 'should return false for weekend dates' do
    Date.parse('Saturday 2009-08-01').weekday?.should be_false
  end
  
end

describe Date, '#previous_weekday' do
  
  it "should return previous weekday" do
    Date.parse('Friday 2009-08-07').previous_weekday.should == Date.parse('Thursday 2009-08-06')
    Date.parse('Monday 2009-08-03').previous_weekday.should == Date.parse('Friday 2009-07-31')
  end
  
end

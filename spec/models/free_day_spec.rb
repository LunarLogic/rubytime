require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe FreeDay do

  it "should be created" do
    block_should(change(FreeDay, :count).by(1)) do
      FreeDay.make(:user => fx(:koza)).save.should be_true
    end
  end

  it "should be created correctly" do
    FreeDay.make(:user => fx(:koza), :date => Date.parse("2009-11-30")).save.should be_true
    FreeDay.is_day_off(fx(:koza), Date.parse("2009-11-30")).should be_true
  end

  describe ".ranges" do
    before do
      FreeDay.all.destroy!
      
      FreeDay.gen :user => fx(:koza),   :date => Date.parse('2009-09-05')
      FreeDay.gen :user => fx(:koza),   :date => Date.parse('2009-09-06')
      FreeDay.gen :user => fx(:koza),   :date => Date.parse('2009-09-08')
      FreeDay.gen :user => fx(:koza),   :date => Date.parse('2009-09-11')
      FreeDay.gen :user => fx(:koza),   :date => Date.parse('2009-09-12')
      FreeDay.gen :user => fx(:koza),   :date => Date.parse('2009-09-13')
      FreeDay.gen :user => fx(:stefan), :date => Date.parse('2009-09-05')
      FreeDay.gen :user => fx(:stefan), :date => Date.parse('2009-09-08')
      FreeDay.gen :user => fx(:stefan), :date => Date.parse('2009-09-11')
      FreeDay.gen :user => fx(:stefan), :date => Date.parse('2009-09-12')
    end
    
    it "should create ranges of free days" do
      ranges = FreeDay.ranges
      
      ranges.size.should == 6
      ranges.should include({ :user => fx(:koza),   :start_date => Date.parse('2009-09-05'), :end_date => Date.parse('2009-09-06') })
      ranges.should include({ :user => fx(:koza),   :start_date => Date.parse('2009-09-08'), :end_date => Date.parse('2009-09-08') })
      ranges.should include({ :user => fx(:koza),   :start_date => Date.parse('2009-09-11'), :end_date => Date.parse('2009-09-13') })
      ranges.should include({ :user => fx(:stefan), :start_date => Date.parse('2009-09-05'), :end_date => Date.parse('2009-09-05') })
      ranges.should include({ :user => fx(:stefan), :start_date => Date.parse('2009-09-08'), :end_date => Date.parse('2009-09-08') })
      ranges.should include({ :user => fx(:stefan), :start_date => Date.parse('2009-09-11'), :end_date => Date.parse('2009-09-12') })
    end
  end
  
  describe ".to_ical" do
    before do
      FreeDay.stub!(:ranges => [
        { :start_date => Date.parse('2009-09-05'), :end_date => Date.parse('2009-09-06'), :user => fx(:koza) },
      ])
    end
    
    it "should render .ics file with free days iCalendar" do
      ical = FreeDay.to_ical

      ical.should =~ /DTSTART:20090905/
      ical.should =~ /DTEND:20090907/
      ical.should =~ /SUMMARY:#{fx(:koza).name}/
    end
  end

end
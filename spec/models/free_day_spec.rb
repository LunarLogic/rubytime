require 'spec_helper'

describe FreeDay do

  it "should be created" do
    block_should(change(FreeDay, :count).by(1)) do
      FreeDay.prepare.save.should be_true
    end
  end

  it "should be created correctly" do
    user = Employee.generate
    FreeDay.prepare(:user => user, :date => date("2009-11-30")).save.should be_true
    user.has_free_day_on(date("2009-11-30")).should be_true
  end

  describe ".ranges" do
    it "should create ranges of free days" do
      user1 = Employee.generate
      user2 = Employee.generate

      FreeDay.all.destroy!
      ['2009-09-05', '2009-09-06', '2009-09-08', '2009-09-11', '2009-09-12', '2009-09-13'].each do |d|
        FreeDay.generate :user => user1, :date => date(d)
      end
      ['2009-09-05', '2009-09-08', '2009-09-11', '2009-09-12'].each do |d|
        FreeDay.generate :user => user2, :date => date(d)
      end

      ranges = FreeDay.ranges
      ranges.size.should == 6

      ranges.should include({ :user => user1, :start_date => date('2009-09-05'), :end_date => date('2009-09-06') })
      ranges.should include({ :user => user1, :start_date => date('2009-09-08'), :end_date => date('2009-09-08') })
      ranges.should include({ :user => user1, :start_date => date('2009-09-11'), :end_date => date('2009-09-13') })
      ranges.should include({ :user => user2, :start_date => date('2009-09-05'), :end_date => date('2009-09-05') })
      ranges.should include({ :user => user2, :start_date => date('2009-09-08'), :end_date => date('2009-09-08') })
      ranges.should include({ :user => user2, :start_date => date('2009-09-11'), :end_date => date('2009-09-12') })
    end
  end

  describe ".to_ical" do
    it "should render .ics file with free days iCalendar" do
      user = Employee.generate
      FreeDay.stub!(:ranges => [
        { :start_date => date('2009-09-05'), :end_date => date('2009-09-06'), :user => user },
      ])

      ical = FreeDay.to_ical
      ical.should =~ /DTSTART:20090905/
      ical.should =~ /DTEND:20090907/
      ical.should =~ /SUMMARY:#{user.name}/
    end
  end

end

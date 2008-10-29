require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Activity do
  it "should be created" do
    block_should(change(Activity, :count).by(1)) do
      Activity.make(:project => fx(:oranges_first_project), :user => fx(:stefan)).save.should be_true 
    end
  end
  
  it "should not be locked when does not belong to invoice" do
    fx(:jolas_activity1).locked?.should be_false
  end

  it "should not be locked when invoice is not locked" do
    fx(:jolas_invoiced_activity).locked?.should be_false
  end
  
  it "should be locked when invoice is locked" do
    fx(:jolas_locked_activity).locked?.should be_true
  end
  
  it "should find n recent activities" do
    10.downto(1) { |i| Activity.gen(:date => Date.today-(i*2)) }
    recent_activities = Activity.recent(3)
    recent_activities.size.should == 3
    recent_activities[0].date.should == Date.today - 2
    recent_activities[1].date.should == Date.today - 4
    recent_activities[2].date.should == Date.today - 6
  end
  
  it "should parse time correctly" do
    a = Activity.new(:hours => 5)
    a.minutes.should == 5 * 60

    a = Activity.new(:hours => "6")
    a.minutes.should == 6 * 60

    a = Activity.new(:hours => "7:15")
    a.minutes.should == 7 * 60 + 15

    a = Activity.new(:hours => " 8.5")
    a.minutes.should == 8.5 * 60

    a = Activity.new(:hours => " 8.90")
    a.minutes.should == 8.9 * 60

    a = Activity.new(:hours => "9,5 ")
    a.minutes.should == 9 * 60 + 30

    a = Activity.new(:hours => 24)
    a.minutes.should == 24 * 60

    a = Activity.new(:hours => 25)
    a.valid?
    a.errors[:hours].size.should == 1

    a = Activity.new(:hours => "1:80")
    a.minutes.should be_nil
    a.valid?
    a.errors[:hours].size.should == 1

    a = Activity.new(:hours => "jola")
    a.minutes.should be_nil
    a.valid?
    a.errors[:hours].size.should == 1
    
    a = Activity.new(:minutes => 123)
    a.valid?
    a.errors[:hours].should be_nil
  end

  it "should raise an ArgumentError when #for called with something else than :now or Hash with :year and :month" do
    args = [ :kiszonka, 
             :nuwee, 
             { :foo => "bar", :year => 123 },
             { :month => 2, :kiszka => "ki5zk4"},
             [:year, :month] ]
    args.each do |arg|
      block_should(raise_argument_error) { fx(:jola).activities.for(arg) }
    end
  end
  
  it "should raise an ArgumentError when #for called with :month not included in 1..12 or future year" do
    [ { :month => 0, :year => 2007 },
      { :month => 13, :year => 2004 },
      { :month => 10, :year => Date.today.year + 1 } ].each do |date|
        block_should(raise_argument_error) { fx(:jola).activities.for(date) }
      end
  end

  it "should return activities for given month" do
    day_number = Date.today.mday
    employee = Employee.gen
    previous_month_count = 8
    this_month_count = 10
    
    previous_month = (month = Date.today.month) == 1 ? 12 : month -1
    year = previous_month == 12 ? Date.today.year - 1 : Date.today.year
     
    previous_month_count.times do 
      Activity.make(:user => employee, :date => Date.today - (day_number + rand(25))).save.should be_true
    end
    this_month_count.times do
      Activity.make(:user => employee, :date => Date.today - (rand(day_number) - 1)).save.should be_true
    end
    # WTF? why it does work sometimes and sometimes doesn't?
    employee.reload.activities.for(:this_month).count.should == this_month_count
    employee.reload.activities.for(:year => year, :month => previous_month).count.should == previous_month_count
  end

  it "should be deletable by admin and by owner" do
    fx(:jolas_activity1).deletable_by?(fx(:jola)).should be_true
    fx(:jolas_activity1).deletable_by?(fx(:admin)).should be_true
    fx(:jolas_activity1).deletable_by?(fx(:stefan)).should be_false
  end
end
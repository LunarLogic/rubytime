require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Activity do
  before(:all) { Activity.all.destroy!; Invoice.all.destroy! }
  
  it "should be created" do
    lambda do
      activity = Activity.make
      activity.project.save.should be_true
      activity.user.save.should be_true
      activity.save.should be_true 
    end.should change(Activity, :count).by(1)
  end
  
  it "should not be locked when does not belong to invoice" do
    activity = Activity.gen
    activity.locked?.should be_false
  end

  it "should not be locked when invoice is not locked" do
    activity = Activity.gen(:invoice => Invoice.gen)
    activity.locked?.should be_false
  end
  
  it "should be locked when invoice is locked" do
    invoice = Invoice.gen(:issued_at => DateTime.now)
    activity = Activity.gen(:invoice => invoice)
    activity.locked?.should be_true
  end
  
  it "should find n recent activities" do
    10.downto(1) { |i| Activity.gen(:date => Date.today-(i*2), :user => Employee.gen, :project => Project.gen ) }
    recent_activities = Activity.recent(3)
    recent_activities.size.should == 3
    recent_activities[0].date.should == Date.today-2
    recent_activities[1].date.should == Date.today-4
    recent_activities[2].date.should == Date.today-6
  end
end

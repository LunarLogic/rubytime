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
end

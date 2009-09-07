require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Invoice do
  it "should be created" do
    block_should(change(Invoice, :count).by(1)) do
      Invoice.make(:client => fx(:orange), :user => fx(:koza)).save.should be_true
    end
  end
  
  it "should be issued if issued_at date is set" do
    Invoice.make.issued?.should be_false
    Invoice.make(:issued_at => DateTime.now).issued?.should be_true
  end

  describe "#invoice" do
    it "should mark invoice as issued and " do
      i = Invoice.gen
#      Activity.(:hourly_rate)
      as = [Activity.gen, Activity.gen]
      i.activities += as
      i.issued?.should be_false
      i.issue!
      i.issued?.should be_true
      i.reload
      # TODO add mocks to retrurn hourly_rate for activities
#      i.activities.map{|a| a.price_saved? }.should == [true, true]
    end 
  end

end

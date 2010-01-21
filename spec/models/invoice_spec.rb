require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Invoice do
  it "should be created" do
    lambda {
      Invoice.make.save.should be_true
    }.should change(Invoice, :count).by(1)
  end
  
  it "should be issued if issued_at date is set" do
    invoice1 = Invoice.gen
    invoice1.should_not be_issued

    invoice2 = Invoice.gen(:issued_at => DateTime.now)
    invoice2.should be_issued
  end

  describe "#issue!" do
    it "should mark invoice as issued" do
      invoice = Invoice.gen
      invoice.should_not be_issued
      invoice.issue!
      invoice.should be_issued
    end 
  end

end

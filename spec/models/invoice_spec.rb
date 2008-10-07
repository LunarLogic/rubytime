require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Invoice do
  before(:all) { }
  
  it "should be created" do
    lambda { Invoice.make.save.should be_true }.should change(Invoice, :count).by(1)
  end
end

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
end

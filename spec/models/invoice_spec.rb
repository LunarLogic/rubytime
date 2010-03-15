require 'spec_helper'

describe Invoice do

  it "should be created" do
    block_should(change(Invoice, :count).by(1)) { Invoice.prepare.save.should be_true }
  end

  it "should be issued if issued_at date is set" do
    invoice1 = Invoice.generate
    invoice1.should_not be_issued

    invoice2 = Invoice.generate :issued_at => DateTime.now
    invoice2.should be_issued
  end

  describe "#issue!" do
    it "should mark invoice as issued" do
      invoice = Invoice.generate
      invoice.should_not be_issued
      invoice.issue!
      invoice.should be_issued
    end 
  end

end

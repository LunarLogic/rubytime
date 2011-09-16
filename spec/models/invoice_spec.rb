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

  context "if some new activities are invalid" do
    it "should not be valid" do
      invoice = Invoice.prepare
      invoice.new_activities = [Activity.new]
      invoice.should_not be_valid

      invoice.new_activities = [Activity.prepare, Activity.new]
      expect { invoice.valid? }.to_not(raise_error)
      invoice.should_not be_valid
    end
  end

  describe "#activity_id" do
    it "should update activites even if no other fields were changed" do
      client = Client.generate
      project = Project.generate :client => client
      activity = Activity.generate :project => project
      invoice = Invoice.generate :client => client

      block_should(change(Activity.not_invoiced, :count).by(-1)) do
        invoice.update(:activity_id => [activity.id])
      end
    end
  end

end

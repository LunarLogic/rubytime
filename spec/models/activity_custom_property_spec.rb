require 'spec_helper'

describe ActivityCustomProperty do
  
  describe "#destroy_allowed?" do
    before { @activity_custom_property = ActivityCustomProperty.generate }
    
    context "when doesn't have any activity_custom_property_values assigned" do
      before { @activity_custom_property.activity_custom_property_values.count.should == 0 }
      
      it { @activity_custom_property.destroy_allowed?.should be_true }
    end
    
    context "when have activity_custom_property_values assigned" do
      before do
        @activity_custom_property.activity_custom_property_values << ActivityCustomPropertyValue.generate
        @activity_custom_property.save
      end
      
      it { @activity_custom_property.destroy_allowed?.should be_false }
    end
  end
  
  describe "#destroy" do
    before { @activity_custom_property = ActivityCustomProperty.generate }
    
    context "when destroy allowed" do
      before { @activity_custom_property.stub!(:destroy_allowed? => true) }
      
      it "should return true" do
        @activity_custom_property.destroy.should be_true
      end
      
      it "should destroy the record" do
        @activity_custom_property.destroy
        ActivityCustomProperty.get(@activity_custom_property.id).should be_nil
      end
    end
    
    context "when destroy not allowed" do
      before { @activity_custom_property.stub!(:destroy_allowed? => false) }
      
      it "should return false" do
        @activity_custom_property.destroy.should be_false
      end
      
      it "should not destroy the record" do
        @activity_custom_property.destroy
        ActivityCustomProperty.get(@activity_custom_property.id).should == @activity_custom_property
      end
    end
  end
  
end

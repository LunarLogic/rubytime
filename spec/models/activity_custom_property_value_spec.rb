require 'spec_helper'

describe ActivityCustomPropertyValue do
  
  describe "#value=" do
    before { @activity_custom_property_value = ActivityCustomPropertyValue.new }
    
    context "for numeric argument" do
      before { @activity_custom_property_value.value = 12.5 }
      it "should assign the value to :numeric_value" do
        @activity_custom_property_value.numeric_value.should == 12.5
      end
    end
    
    context "for nil argument" do
      before { @activity_custom_property_value.value = nil }
      it "should assign nil to :numeric_value" do
        @activity_custom_property_value.numeric_value.should == nil
      end
    end
    
    context "for blank string argument" do
      before { @activity_custom_property_value.value = "" }
      it "should assign nil to :numeric_value" do
        @activity_custom_property_value.numeric_value.should == nil
      end
    end
  end
  
  describe "#value" do
    before { @activity_custom_property_value = ActivityCustomPropertyValue.new }
    
    context "when :numeric_value has integer value" do
      before { @activity_custom_property_value.numeric_value = 59 }
      
      it "should return that value" do
        @activity_custom_property_value.value.should == 59
      end
      
      it "should return fixnum value" do
        @activity_custom_property_value.value.should be_instance_of(Fixnum)
      end
    end
    
    context "when :numeric_value has float value" do
      before { @activity_custom_property_value.numeric_value = 12.97 }
      
      it "should return that value" do
        @activity_custom_property_value.value.should == 12.97
      end
      
      it "should return float value" do
        @activity_custom_property_value.value.should be_instance_of(Float)
      end
    end
    
    context "when :numeric_value is nil" do
      before { @activity_custom_property_value.numeric_value = nil }
      
      it "should return nil" do
        @activity_custom_property_value.value.should == nil
      end
    end
  end
  
  context "with blank :value" do
    before { @activity_custom_property_value = ActivityCustomPropertyValue.new(:value => nil) }
    
    it { @activity_custom_property_value.should have_errors_on(:value) }
  end
  
end

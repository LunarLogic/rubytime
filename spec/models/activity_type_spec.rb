require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe ActivityType do

  describe "#destroy_allowed?" do
    before { @activity_type = ActivityType.generate! }
    
    context "when not assigned to any projects" do
      it { @activity_type.destroy_allowed?.should be_true }
    end
    
    context "when assigned to projects" do
      before do
        @activity_type.projects << Project.generate!(:client => Client.generate!)
        @activity_type.save
      end
      
      it { @activity_type.destroy_allowed?.should be_false }
    end
    
    context "when has children that are not allowed to destroy" do
      before do
        child_activity_type = ActivityType.generate!
        child_activity_type.projects << Project.generate!(:client => Client.generate!)
        child_activity_type.save
        
        @activity_type.children << child_activity_type
        @activity_type.save
      end
      
      it { @activity_type.destroy_allowed?.should be_false }
    end
  end
  
  describe "#destroy" do
    before { @activity_type = ActivityType.generate! }
    
    context "when destroy allowed" do
      before { @activity_type.stub!(:destroy_allowed? => true) }
      
      it "should return true" do
        @activity_type.destroy.should be_true
      end
      
      it "should destroy the record" do
        @activity_type.destroy
        ActivityType.get(@activity_type.id).should be_nil
      end
    end
    
    context "when destroy not allowed" do
      before { @activity_type.stub!(:destroy_allowed? => false) }
      
      it "should return false" do
        @activity_type.destroy.should be_false
      end
      
      it "should not destroy the record" do
        @activity_type.destroy
        ActivityType.get(@activity_type.id).should == @activity_type
      end
      
      context "with force => true" do
        it "should return true" do
          @activity_type.destroy(true).should be_true
        end

        it "should destroy the record" do
          @activity_type.destroy(true)
          ActivityType.get(@activity_type.id).should be_nil
        end
      end
    end
  end

end
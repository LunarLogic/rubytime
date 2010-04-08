require 'spec_helper'

describe ActivityType do

  it "should nullify parent_id if it's an empty string" do
    type1 = ActivityType.generate
    type2 = ActivityType.prepare :parent_id => type1.id
    type2.parent_id.should == type1.id

    type2.parent_id = ''
    type2.parent_id.should be_nil
  end

  describe "#breadcrumb_name" do
    before do
      @activity_type_AAA = ActivityType.new :name => 'AAA'
      @activity_type_BBB = ActivityType.new :name => 'BBB', :parent => @activity_type_AAA
      @activity_type_CCC = ActivityType.new :name => 'CCC', :parent => @activity_type_BBB
    end
    
    it "should properly generate breadcrumb string" do
      @activity_type_AAA.breadcrumb_name.should == 'AAA'
      @activity_type_BBB.breadcrumb_name.should == 'AAA -> BBB'
      @activity_type_CCC.breadcrumb_name.should == 'AAA -> BBB -> CCC'
    end
  end

  describe "#destroy_allowed?" do
    before { @activity_type = ActivityType.generate }
    
    context "when not assigned to any projects" do
      it { @activity_type.destroy_allowed?.should be_true }
    end
    
    context "when assigned to projects" do
      before do
        @activity_type.projects << Project.generate
        @activity_type.save
      end
      
      it { @activity_type.destroy_allowed?.should be_false }
    end
    
    context "when assigned to activities" do
      before do
        @activity_type.activities << Activity.generate
        @activity_type.save
      end
      
      it { @activity_type.destroy_allowed?.should be_false }
    end
    
    context "when has children that are not allowed to destroy" do
      before do
        child_activity_type = ActivityType.generate
        child_activity_type.projects << Project.generate
        child_activity_type.save
        
        @activity_type.children << child_activity_type
        @activity_type.save
      end
      
      it { @activity_type.destroy_allowed?.should be_false }
    end
  end
  
  describe "#destroy" do
    before { @activity_type = ActivityType.generate }
    
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
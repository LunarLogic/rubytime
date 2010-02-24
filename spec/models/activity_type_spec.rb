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
    
    context "when assigned to activities" do
      before do
        @activity_type.activities << Activity.generate!(:project => Project.generate!(:client => Client.generate!))
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
  
  describe ".available" do
    before do
      @activity_type_A  = ActivityType.generate
      @activity_type_B  = ActivityType.generate
      @activity_type_B1 = ActivityType.generate(:parent => @activity_type_B)
      @activity_type_B2 = ActivityType.generate(:parent => @activity_type_B)
      @activity_type_C  = ActivityType.generate
      @activity_type_C1 = ActivityType.generate(:parent => @activity_type_C)
      @activity_type_D  = ActivityType.generate
      
      @project = Project.generate(:client => Client.generate)
      @project.activity_types = [@activity_type_A, @activity_type_B, @activity_type_B2]
      @project.save
    end
    
    context "for project that is nil" do
      it "should return proper values" do
        activity_types = ActivityType.available(nil, nil)
        activity_types.size.should == 0
      end
    end
    
    context "for project" do
      it "should return proper values" do
        activity_types = ActivityType.available(@project, nil)
        activity_types.size.should == 2
        activity_types.should include(@activity_type_A)
        activity_types.should include(@activity_type_B)
      end
    end
    
    context "for project and activity" do
      context "with root level activity type" do
        context "that is assigned to the project" do
          before { @activity = Activity.gen(:activity_type => @activity_type_A) }
      
          it "should return proper values" do
            activity_types = ActivityType.available(@project, nil, @activity)
            activity_types.size.should == 2
            activity_types.should include(@activity_type_A)
            activity_types.should include(@activity_type_B)
          end
        end
        
        context "that is not assigned to the project" do
          before { @activity = Activity.gen(:activity_type => @activity_type_D) }
      
          it "should return proper values" do
            activity_types = ActivityType.available(@project, nil, @activity)
            activity_types.size.should == 3
            activity_types.should include(@activity_type_A)
            activity_types.should include(@activity_type_B)
            activity_types.should include(@activity_type_D)
          end
        end
      end
      
      context "with root level activity type" do
        before { @activity = Activity.gen(:activity_type => @activity_type_D) }
      
        it "should return proper values" do
          activity_types = ActivityType.available(@project, nil, @activity)
          activity_types.size.should == 3
          activity_types.should include(@activity_type_A)
          activity_types.should include(@activity_type_B)
          activity_types.should include(@activity_type_D)
        end
      end
      
      context "with sub level activity type" do
        before { @activity = Activity.gen(:activity_type => @activity_type_C1) }
      
        it "should return proper values" do
          activity_types = ActivityType.available(@project, nil, @activity)
          activity_types.size.should == 3
          activity_types.should include(@activity_type_A)
          activity_types.should include(@activity_type_B)
          activity_types.should include(@activity_type_C)
        end
      end
    end
    
    context "for project and main activity type" do
      it "should return proper values" do
        activity_types = ActivityType.available(@project, @activity_type_B)
        activity_types.size.should == 1
        activity_types.should include(@activity_type_B2)
      end
    end
    
    context "for project and main activity type and activity" do
      context "with root level activity type" do  
        before { @activity = Activity.gen(:activity_type => @activity_type_C) }
      
        it "should return proper values" do
          activity_types = ActivityType.available(@project, @activity_type_B, @activity)
          activity_types.size.should == 1
          activity_types.should include(@activity_type_B2)
        end
      end
      
      context "with sub level activity type" do
        context "that is assigned to the project" do
          before { @activity = Activity.gen(:activity_type => @activity_type_B2) }
      
          it "should return proper values" do
            activity_types = ActivityType.available(@project, @activity_type_B, @activity)
            activity_types.size.should == 1
            activity_types.should include(@activity_type_B2)
          end
        end
        
        context "that is not assigned to the project" do
          context "and is a child of the activity type" do  
            before { @activity = Activity.gen(:activity_type => @activity_type_B1) }

            it "should return proper values" do
              activity_types = ActivityType.available(@project, @activity_type_B, @activity)
              activity_types.size.should == 2
              activity_types.should include(@activity_type_B1)
              activity_types.should include(@activity_type_B2)
            end
          end

          context "and is not a child of the activity type" do  
            before { @activity = Activity.gen(:activity_type => @activity_type_C1) }

            it "should return proper values" do
              activity_types = ActivityType.available(@project, @activity_type_B, @activity)
              activity_types.size.should == 1
              activity_types.should include(@activity_type_B2)
            end
          end
        end
      end
    end
  end

end
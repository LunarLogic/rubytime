require 'spec_helper'

describe Estimate do
  
  describe "#minutes=" do
    before { @estimate = Estimate.new }
    
    context "for numeric argument" do
      before { @estimate.minutes = 12 }
      it "should assign the value to :minutes" do
        @estimate.minutes.should == 12
      end
    end
    
    context "for nil argument" do
      before { @estimate.minutes = nil }
      it "should assign nil to :minutes" do
        @estimate.minutes.should == nil
      end
    end
    
    context "for blank string argument" do
      before { @estimate.minutes = "" }
      it "should assign nil to :minutes" do
        @estimate.minutes.should == nil
      end
    end
  end
  
  describe "#minutes_to_go=" do
    before { @estimate = Estimate.new }
    
    context "for numeric argument" do
      before { @estimate.minutes_to_go = 12 }
      it "should assign the value to :minutes_to_go" do
        @estimate.minutes_to_go.should == 12
      end
    end
    
    context "for nil argument" do
      before { @estimate.minutes_to_go = nil }
      it "should assign nil to :minutes_to_go" do
        @estimate.minutes_to_go.should == nil
      end
    end
    
    context "for blank string argument" do
      before { @estimate.minutes_to_go = "" }
      it "should assign nil to :minutes_to_go" do
        @estimate.minutes_to_go.should == nil
      end
    end
  end

  describe "#save_or_destroy" do
    before { @estimate = Estimate.new }

    context "when :minutes is not nil" do
      before { @estimate.minutes = 10 }

      it "should save the resource" do
        @estimate.should_receive(:save)
        @estimate.save_or_destroy
      end

      it "should return value returned by save method" do
        @estimate.stub(:save => :value_returned_by_save)
        @estimate.save_or_destroy.should == :value_returned_by_save
      end
    end

    context "when :minutes_to_go is not nil" do
      before { @estimate.minutes_to_go = 20 }

      it "should save the resource" do
        @estimate.should_receive(:save)
        @estimate.save_or_destroy
      end

      it "should return value returned by save method" do
        @estimate.stub(:save => :value_returned_by_save)
        @estimate.save_or_destroy.should == :value_returned_by_save
      end
    end

    context "when :minutes and :minutes_to_go are nil" do
      before { @estimate.minutes = nil; @estimate.minutes_to_go = nil }

      context "and resource is a new instance" do
        before { @estimate.stub(:new? => true) }

        it "should not call :destroy on the resource" do
          @estimate.should_not_receive(:destroy)
          @estimate.save_or_destroy
        end

        it "should return true" do
          @estimate.save_or_destroy.should be_true
        end
      end

      context "and resource is a saved instance" do
        before { @estimate.stub(:new? => false) }

        it "should destroy the resource" do
          @estimate.should_receive(:destroy)
          @estimate.save_or_destroy
        end

        it "should return value returned by destroy method" do
          @estimate.stub(:destroy => :value_returned_by_destroy)
          @estimate.save_or_destroy.should == :value_returned_by_destroy
        end
      end
    end
  end

  context "with blank :minutes" do
    before { @estimate = Estimate.new :minutes => nil }

    context "when minutes_to_go is not nil" do
      before { @estimate.minutes_to_go = 15 }

      it { @estimate.should have_errors_on(:minutes) }
    end
  end

  context "with :minutes greater than Estimate::MAX_MINUTES" do
    before { @estimate = Estimate.new :minutes => Estimate::MAX_MINUTES + 1, :minutes_to_go => 5 }

    it { @estimate.should have_errors_on(:minutes) }
  end

  context "with :minutes_to_go greater than Estimate::MAX_MINUTES" do
    before { @estimate = Estimate.new :minutes => Estimate::MAX_MINUTES + 2, :minutes_to_go => Estimate::MAX_MINUTES + 1 }

    it { @estimate.should have_errors_on(:minutes_to_go) }
  end

  context "with :minutes having decimal part" do
    before { @estimate = Estimate.new :minutes => 10.5, :minutes_to_go => 5 }

    it { @estimate.should have_errors_on(:minutes) }
  end

  context "with :minutes_to_go having decimal part" do
    before { @estimate = Estimate.new :minutes => 10, :minutes_to_go => 5.5 }

    it { @estimate.should have_errors_on(:minutes_to_go) }
  end

  context "with :minutes_to_go greater than :minutes" do
    before { @estimate = Estimate.new :minutes => 5, :minutes_to_go => 6 }

    it { @estimate.should have_errors_on(:minutes_to_go) }
  end

  describe "#validates_minutes_to_go" do
    context "when :minutes is string and :minutes_to_go is integer" do
      before { @estimate = Estimate.new :minutes => 'five', :minutes_to_go => 4 }

      it "should not crash" do
        lambda { @estimate.save }.should_not raise_error(ArgumentError)
      end
    end
  end
end

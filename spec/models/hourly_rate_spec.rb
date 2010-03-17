require 'spec_helper'

describe HourlyRate do

  describe ":value accessor" do
    it "should work with numbers" do
      hr = HourlyRate.generate :value => 567.89
      HourlyRate.get(hr.id).value.should == 567.89
    end

    it "should work with empty string" do
      hourly_rate = HourlyRate.prepare :value => ''
      hourly_rate.value.should == nil
    end

    it "should work with nil" do
      hourly_rate = HourlyRate.prepare :value => nil
      hourly_rate.value.should == nil
    end
  end

  describe "#value_formatted" do
    it "should return formatted :value attribute" do
      hourly_rate = HourlyRate.new :value => 123.45
      hourly_rate.value_formatted.should == '123.45'
    end
  end

  it "should not allow to save record without :project assigned" do
    hourly_rate = HourlyRate.prepare :project => nil
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:project_id).should_not be_nil
  end

  it "should not allow to save record without :role assigned" do
    hourly_rate = HourlyRate.prepare :role => nil
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:role_id).should_not be_nil
  end

  it "should not allow to save record without :takes_effect_at" do
    hourly_rate = HourlyRate.prepare :takes_effect_at => ''
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:takes_effect_at).should_not be_nil
  end

  it "should not allow to save record without :value" do
    hourly_rate = HourlyRate.prepare :value => ''
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:value).should_not be_nil
  end

  it "should not allow to save record without :currency" do
    hourly_rate = HourlyRate.prepare :currency => nil
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:currency_id).should_not be_nil
  end

  it "should not allow to save record with the same set of :project, :role and :takes_effect_at" do
    HourlyRate.all.destroy!

    attributes = { :project => Project.generate, :role => Role.generate, :takes_effect_at => Date.today }

    hourly_rate = HourlyRate.prepare(attributes)
    duplicated_hourly_rate = HourlyRate.prepare(attributes)

    hourly_rate.save.should be_true
    duplicated_hourly_rate.save.should be_false
    duplicated_hourly_rate.errors.on(:takes_effect_at).should_not be_nil
  end

  it "should not allow to save record without :operation_author assigned" do
    hourly_rate = HourlyRate.prepare :operation_author => nil
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:operation_author).should_not be_nil
  end

  context "if there are activities that use it" do
    before do
      @project = Project.generate
      @role = Role.first_or_generate
      @user = Employee.generate :role => @role
      @hourly_rate = HourlyRate.generate :project => @project, :role => @role, :takes_effect_at => date("2009-09-04")
      Activity.all.destroy!
      Activity.generate :project => @project, :user => @user, :date => date("2009-09-06")
    end

    it "should not allow to destroy the record" do
      @hourly_rate.destroy.should be_nil
      HourlyRate.get(@hourly_rate.id).should_not be_nil
      @hourly_rate.errors.on(:base).should_not be_nil
    end
  end

  context "if there are no activities that use it" do
    before do
      @project = Project.generate
      @users = Role.generate
      @managers = Role.generate
      @manager = Employee.generate :role => @managers
      @hourly_rate = HourlyRate.generate :project => @project, :role => @users, :takes_effect_at => date("2009-09-04")
      Activity.all.destroy!
      Activity.generate :project => @project, :user => @manager, :date => date("2009-09-06")
    end

    it "should allow to destroy the record" do
      @hourly_rate.destroy.should be_true
      HourlyRate.get(@hourly_rate.id).should be_nil
    end
  end

  it "should have default order by :takes_effect_at" do
    HourlyRate.all.destroy!

    hr1 = HourlyRate.generate :takes_effect_at => Date.today - 2
    hr2 = HourlyRate.generate :takes_effect_at => Date.today
    hr3 = HourlyRate.generate :takes_effect_at => Date.today - 4

    HourlyRate.all.should == [hr3, hr1, hr2]
  end

  it "should return HourlyRate object for specified activity" do 
    HourlyRate.all.destroy!

    hr1 = HourlyRate.generate :takes_effect_at => date("2009-09-01")
    hr2 = HourlyRate.generate :takes_effect_at => date("2009-08-01"), :project => hr1.project, :role => hr1.role

    [hr1.role_id, hr1.project_id].should == [hr2.role_id, hr2.project_id]

    user = Employee.generate :role => hr1.role

    activity = Activity.new :project => hr1.project, :user => user, :date => date("2009-08-02")
    hr = HourlyRate.find_for_activity(activity)
    hr.should be_a_kind_of(HourlyRate)
    hr.should == hr2
  end

  describe "#to_money" do
    it "should return proper Money object" do
      euro = Currency.generate
      hourly_rate = HourlyRate.generate :value => 44.88, :currency => euro
      hourly_rate.to_money.should be_instance_of(Money)
      hourly_rate.to_money.should == Money.new(44.88, euro)
    end
  end

  describe "#*" do
    it "should return properly calculated Money object" do
      euro = Currency.generate
      hourly_rate = HourlyRate.generate :value => 44.88, :currency => euro
      (hourly_rate * 0.5).should be_instance_of(Money)
      (hourly_rate * 0.5).should == Money.new(22.44, euro)
    end
  end

  describe "#succ" do
    before { HourlyRate.all.destroy! }

    context "if successor hourly rate exists" do
      before do
        p = Project.generate
        r = Role.generate
        @hourly_rate_A = HourlyRate.generate :takes_effect_at => date("2009-09-04"), :project => p, :role => r
        @hourly_rate_B = HourlyRate.generate :takes_effect_at => date("2009-09-02"), :project => p, :role => r
      end

      it "should return it" do
        @hourly_rate_B.succ.should == @hourly_rate_A
      end
    end

    context "if successor hourly rate doesn't exists" do
      before do
        @hourly_rate = HourlyRate.generate :takes_effect_at => Date.parse("2009-09-04")
      end

      it "should return nil" do
        @hourly_rate.succ.should be_nil
      end
    end

    context "if there are hourly rates for this and other projects" do
      before do
        p1 = Project.generate
        p2 = Project.generate
        r = Role.generate
        @hourly_rate_A = HourlyRate.generate :project => p1, :role => r, :takes_effect_at => date("2009-09-04")
        @hourly_rate_B = HourlyRate.generate :project => p1, :role => r, :takes_effect_at => date("2009-09-02")
        @hourly_rate_C = HourlyRate.generate :project => p2, :role => r, :takes_effect_at => date("2009-09-03")
      end

      it "should return only rates of the same project" do
        @hourly_rate_B.succ.should == @hourly_rate_A
      end
    end

    context "if there are hourly rates for this and other roles" do
      before do
        p = Project.generate
        r1 = Role.generate
        r2 = Role.generate
        @hourly_rate_A = HourlyRate.generate :project => p, :role => r1, :takes_effect_at => date("2009-09-04")
        @hourly_rate_B = HourlyRate.generate :project => p, :role => r2, :takes_effect_at => date("2009-09-03")
        @hourly_rate_C = HourlyRate.generate :project => p, :role => r1, :takes_effect_at => date("2009-09-02")
      end

      it "should return only rates of the same project" do
        @hourly_rate_C.succ.should == @hourly_rate_A
      end
    end

  end

  describe "#activities" do
    before do
      Activity.all.destroy!

      @project = Project.generate
      @devs = Role.generate
      @user1 = Employee.generate :role => @devs
      @user2 = Employee.generate :role => @devs

      @activityA = Activity.generate :project => @project, :user => @user1, :date => date("2009-09-01")
      @activityB = Activity.generate :project => @project, :user => @user1, :date => date("2009-09-02")
      @activityC = Activity.generate :project => @project, :user => @user2, :date => date("2009-09-03")
      @activityD = Activity.generate :project => @project, :user => @user1, :date => date("2009-09-04")
      @activityE = Activity.generate :project => @project, :user => @user2, :date => date("2009-09-05")
    end

    context "if successor hourly rate exists" do
      before do
        @rateA = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-04")
        @rateB = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-02")
      end

      it "should return activities that hourly rate relates to" do
        @rateB.activities.should == [@activityB, @activityC]
      end
    end

    context "if successor hourly rate doesn't exists" do
      before do
        @rate = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-02")
      end
      
      it "should return nil" do
        @rate.activities.should == [@activityB, @activityC, @activityD, @activityE]
      end
    end

    context "if there are activities for this and other projects" do
      before do
        @project2 = Project.generate
        Activity.generate :project => @project2, :user => @user1, :date => date("2009-09-02")
        Activity.generate :project => @project2, :user => @user1, :date => date("2009-09-03")

        @rateA = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-04")
        @rateB = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-02")
      end

      it "should return activities that hourly rate relates to" do
        @rateB.activities.should == [@activityB, @activityC]
      end
    end

    context "if there are activities for this and other roles" do
      before do
        @testers = Role.generate
        @user3 = Employee.generate :role => @testers
        @user4 = Employee.generate :role => @testers

        Activity.generate :project => @project, :user => @user3, :date => date("2009-09-02")
        Activity.generate :project => @project, :user => @user4, :date => date("2009-09-03")

        @rateA = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-04")
        @rateB = HourlyRate.generate :project => @project, :role => @devs, :takes_effect_at => date("2009-09-02")
      end

      it "should return activities that hourly rate relates to" do
        @rateB.activities.should == [@activityB, @activityC]
      end
    end

  end
end

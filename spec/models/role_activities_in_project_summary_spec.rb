require 'spec_helper'

describe RoleActivitiesInProjectSummary do

  before :all do
    @euro = Currency.first_or_generate :singular_name => 'euro'
    @dollar = Currency.first_or_generate :singular_name => 'dollar'
  end

  context "without any activities" do
    before do
      @user = mock('user', :role => mock('role'))
      @summary = RoleActivitiesInProjectSummary.new(@user.role, [])
    end

    it "should create the summary" do
      @summary.role.should               == @user.role
      @summary.non_billable_time.should  == 0
      @summary.billable_time.should      == 0
      @summary.price[@euro].should       == Money.new(0, @euro)
      @summary.price[@dollar].should     == Money.new(0, @dollar)
    end
  end

  context "with some activities" do
    before do
      @role = mock('role')
      @user = mock('user', :role => @role)
      @summary = RoleActivitiesInProjectSummary.new(@user.role, [
        mock('activity', :role => @role, :duration => 1.hour,              :price => Money.new(20, @euro)),
        mock('activity', :role => @role, :duration => 1.hour + 20.minutes, :price => nil),
        mock('activity', :role => @role, :duration =>          15.minutes, :price => Money.new( 7, @dollar)),
        mock('activity', :role => @role, :duration =>          45.minutes, :price => nil),
        mock('activity', :role => @role, :duration =>           5.minutes, :price => Money.new(11, @euro))
      ])
    end

    it "should create the summary" do
      @summary.role.should               == @user.role
      @summary.non_billable_time.should  == 2.hours +  5.minutes
      @summary.billable_time.should      == 1.hour  + 20.minutes
      @summary.price[@euro].should       == Money.new(31, @euro)
      @summary.price[@dollar].should     == Money.new(7, @dollar)
    end
  end

  describe "#<<" do
    before do
      @role = mock('role')
      @summary = RoleActivitiesInProjectSummary.new(@role, [])
    end

    context "if called with activity of proper role" do
      before { @summary << mock('activity', :role => @role, :duration => 1.hour, :price => nil) }
      it "should add activity" do
        @summary.non_billable_time.should == 1.hour
      end
    end

    context "if called with activity of improper role" do
      it "should add activity" do
        block_should(raise_error(ArgumentError)) do
          @summary << mock('activity',
            :role => mock('another role'),
            :duration => 1.hour,
            :price => nil
          )
        end
      end
    end
  end

end

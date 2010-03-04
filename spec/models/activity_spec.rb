require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Activity do
  it "should be created" do
    block_should(change(Activity, :count).by(1)) do
      Activity.make(
        :project => fx(:oranges_first_project), 
        :activity_type => fx(:oranges_first_project).activity_types.first, 
        :user => fx(:stefan)
      ).save.should be_true
    end
  end
  
  context "with empty :comments property" do
    before { @activity = Activity.new(:comments => "") }
    
    context "when activity_type assigned" do
      before { @activity.activity_type = ActivityType.gen }
      it { @activity.should_not have_errors_on(:comments) }
    end
    
    context "when activity_type not assigned" do
      before { @activity.activity_type = nil }
      it { @activity.should have_errors_on(:comments) }
    end
  end
  
  context "with not empty :comments property" do
    before { @activity = Activity.new(:comments => "Some comments") }
    
    context "when activity_type assigned" do
      before { @activity.activity_type = ActivityType.gen }
      it { @activity.should_not have_errors_on(:comments) }
    end
    
    context "when activity_type not assigned" do
      before { @activity.activity_type = nil }
      it { @activity.should_not have_errors_on(:comments) }
    end
  end
  
  context "with no project assigned" do
    before { @activity = Activity.new(:project => nil) }
    
    context "with nil activity_type" do
      before { @activity.activity_type = nil }
      it { @activity.should_not have_errors_on(:activity_type_id) }
    end
    
    context "with activity_type" do
      before { @activity.activity_type = ActivityType.gen }
      it { @activity.should have_errors_on(:activity_type_id) }
    end
  end
  
  context "with project assigned" do
    before do
      @project = Project.gen(:client => Client.gen)
      @activity = Activity.gen(:project => @project)
    end

    context "when project has activity_types assigned" do
      before do
        @activity_type = ActivityType.gen
        @project.activity_type_projects.create(:activity_type => @activity_type)
      end
      
      context "with nil activity_type" do
        before { @activity.activity_type = nil }
        it { @activity.should have_errors_on(:activity_type_id) }
      end

      context "with activity_type that is also assigned to the project" do
        before { @activity.activity_type = @activity_type }
        it { @activity.should_not have_errors_on(:activity_type_id) }
      end
      
      context "with activity_type that is not assigned to the project" do
        before { @activity.activity_type = ActivityType.gen }
        it { @activity.should have_errors_on(:activity_type_id) }
      end
    end
    
    context "when project has no activity_types assigned" do
      before { @project.activity_types.count.should == 0 }
      
      context "with nil activity_type" do
        before { @activity.activity_type = nil }
        it { @activity.should_not have_errors_on(:activity_type_id) }
      end
      
      context "with activity_type assigned" do
        before { @activity.activity_type = ActivityType.gen }
        it { @activity.should have_errors_on(:activity_type_id) }
      end
    end
    
  end

  it "should not be locked when does not belong to invoice" do
    fx(:jolas_activity1).locked?.should be_false
  end

  it "should not be locked when invoice is not locked" do
    fx(:jolas_invoiced_activity).locked?.should be_false
  end

  it "should be locked when invoice is locked" do
    fx(:jolas_locked_activity).locked?.should be_true
  end

  it "should find n recent activities" do
    10.downto(1) { |i| Activity.gen(:date => Date.today-(i*2)) }
    recent_activities = Activity.recent(3)
    recent_activities.size.should == 3
    recent_activities[0].date.should == Date.today - 2
    recent_activities[1].date.should == Date.today - 4
    recent_activities[2].date.should == Date.today - 6
  end
  
  it "should parse time correctly" do
    a = Activity.new(:hours => 5)
    a.minutes.should == 5 * 60

    a = Activity.new(:hours => "6")
    a.minutes.should == 6 * 60

    a = Activity.new(:hours => "7:15")
    a.minutes.should == 7 * 60 + 15

    a = Activity.new(:hours => " 8.5")
    a.minutes.should == 8.5 * 60

    a = Activity.new(:hours => " 8.9")
    a.minutes.should == 8.9 * 60

    a = Activity.new(:hours => "9,5 ")
    a.minutes.should == 9 * 60 + 30

    a = Activity.new(:hours => 24)
    a.minutes.should == 24 * 60

    a = Activity.new(:hours => 25)
    a.valid?
    a.minutes.should be_nil
    a.errors[:hours].size.should == 1

    a = Activity.new(:hours => "24:01")
    a.valid?
    a.minutes.should be_nil
    a.errors[:hours].size.should == 1

    a = Activity.new(:hours => "1:80")
    a.valid?
    a.minutes.should be_nil
    a.errors[:hours].size.should == 1

    a = Activity.new(:hours => "jola")
    a.valid?
    a.minutes.should be_nil
    a.errors[:hours].size.should == 1

    a = Activity.new(:minutes => 123)
    a.valid?
    a.errors[:hours].should be_nil
  end
  
  it "should return formatted hours for saved activity" do
    a = Activity.gen(:project => fx(:oranges_first_project), :user => fx(:jola), :minutes => 7.5 * 60, :activity_type => fx(:oranges_first_project).activity_types.first)
    a = Activity.get(a.id)
    a.hours.should == "7:30"
  end

  it "should return entered hours for new activity" do
    a = Activity.new(:hours => "3,5")
    a.hours.should == "3,5"
  end

  it "should raise an ArgumentError when #for called with something else than :now or Hash with :year and :month" do
    args = [ :kiszonka,
             :nuwee,
             { :foo => "bar", :year => 123 },
             { :month => 2, :kiszka => "ki5zk4"},
             [:year, :month] ]
    args.each do |arg|
      block_should(raise_argument_error) { fx(:jola).activities.for(arg) }
    end
  end

  it "should raise an ArgumentError when #for called with :month not included in 1..12 or future year" do
    [ { :month => 0, :year => 2007 },
      { :month => 13, :year => 2004 },
      { :month => 10, :year => Date.today.year + 1 } ].each do |date|
        block_should(raise_argument_error) { fx(:jola).activities.for(date) }
      end
  end

  it "should return activities for given month" do
    day_number = Date.today.mday
    employee = Employee.gen
    previous_month_count = 8
    this_month_count = 10

    previous_month = (month = Date.today.month) == 1 ? 12 : month -1
    year = previous_month == 12 ? Date.today.year - 1 : Date.today.year

    previous_month_count.times do
      Activity.make(:user => employee, :date => Date.today - (day_number + rand(25))).save.should be_true
    end
    this_month_count.times do
      Activity.make(:user => employee, :date => Date.today - (rand(day_number) - 1)).save.should be_true
    end
    # WTF? why it does work sometimes and sometimes doesn't?
    employee.reload.activities.for(:this_month).count.should == this_month_count
    employee.reload.activities.for(:year => year, :month => previous_month).count.should == previous_month_count
  end

  it "should return activities for first and last day of month" do
    employee = Employee.gen
    Activity.make(:user => employee, :date => Date.parse("2008-11-01")).save.should be_true
    Activity.make(:user => employee, :date => Date.parse("2008-11-30")).save.should be_true
    employee.reload.activities.for(:year => 2008, :month => 11).count.should == 2
  end

  it "should be deletable by admin and by owner" do
    fx(:jolas_activity1).deletable_by?(fx(:jola)).should be_true
    fx(:jolas_activity1).deletable_by?(fx(:admin)).should be_true
    fx(:jolas_activity1).deletable_by?(fx(:stefan)).should be_false
  end

  it "should check if activity exist for date" do
    Activity.make(:project => fx(:oranges_first_project), :activity_type => fx(:oranges_first_project).activity_types.first, :user => fx(:stefan), :date => Date.parse("2008-11-23")).save.should be_true
    Activity.is_activity_day(fx(:stefan), Date.parse("2008-11-23")).should be_true
  end
  
  describe "main- and sub- activity_type_id setters" do
    before do
      @activity_type_A  = ActivityType.gen
      @activity_type_B  = ActivityType.gen
      @activity_type_B1 = ActivityType.gen(:parent => @activity_type_B)
      @activity_type_B2 = ActivityType.gen(:parent => @activity_type_B)
      
      @activity = Activity.gen
    end
    
    context "when setting to nil" do
      before do
        @activity.main_activity_type_id = nil
        @activity.sub_activity_type_id = nil
      end
      
      it "should set proper activity_type" do
        @activity.activity_type.should be_nil
      end
    end
    
    context "when setting to nil (reverse order)" do
      before do
        @activity.sub_activity_type_id = nil
        @activity.main_activity_type_id = nil
      end
      
      it "should set proper activity_type" do
        @activity.activity_type.should be_nil
      end
    end

    context "when setting only main- activity_type_id" do
      before do
        @activity.main_activity_type_id = @activity_type_A.id
        @activity.sub_activity_type_id = nil
      end
      
      it "should set proper activity_type" do
        @activity.activity_type.should == @activity_type_A
      end
    end
    
    context "when setting only main- activity_type_id (reverse order)" do
      before do
        @activity.sub_activity_type_id = nil
        @activity.main_activity_type_id = @activity_type_A.id
      end
      
      it "should set proper activity_type" do
        @activity.activity_type.should == @activity_type_A
      end
    end
    
    context "when setting both main- and sub- activity_type_id" do
      before do
        @activity.main_activity_type_id = @activity_type_B.id
        @activity.sub_activity_type_id = @activity_type_B1.id
      end
      
      it "should set proper activity_type" do
        @activity.activity_type.should == @activity_type_B1
      end
    end
    
    context "when setting both main- and sub- activity_type_id (reverse order)" do
      before do
        @activity.sub_activity_type_id = @activity_type_B1.id
        @activity.main_activity_type_id = @activity_type_B.id
      end
      
      it "should set proper activity_type" do
        @activity.activity_type.should == @activity_type_B1
      end
    end
  end
  
  describe "main- and sub- activity_type_id getters" do
    before do
      @activity_type_A  = ActivityType.gen
      @activity_type_B  = ActivityType.gen
      @activity_type_B1 = ActivityType.gen(:parent => @activity_type_B)
      @activity_type_B2 = ActivityType.gen(:parent => @activity_type_B)
      
      @activity = Activity.gen
    end
    
    context "when activity_type is nil" do
      before do
        @activity.activity_type = nil
      end
      
      it "should get proper values" do
        @activity.main_activity_type_id.should be_nil
        @activity.sub_activity_type_id.should be_nil
      end
    end
    
    context "when activity_type is one of root activity types" do
      before do
        @activity.activity_type = @activity_type_A
      end
      
      it "should get proper values" do
        @activity.main_activity_type_id.should == @activity_type_A.id
        @activity.sub_activity_type_id.should be_nil
      end
    end

    context "when activity_type is one of sub activity types" do
      before do
        @activity.activity_type = @activity_type_B2
      end
      
      it "should get proper values" do
        @activity.main_activity_type_id.should == @activity_type_B.id
        @activity.sub_activity_type_id.should  == @activity_type_B2.id
      end
    end

  end
  
  describe "#full_type_name" do
    context "when no activity type assigned" do
      before { @activity = Activity.gen(:activity_type => nil) }
      it "should return nil" do
        @activity.full_type_name.should be_nil
      end
    end
    
    context "when main activity type assigned" do
      before { @activity = Activity.gen(:activity_type => ActivityType.gen(:name => 'Main Type', :parent => nil)) }
      it "should return the name" do
        @activity.full_type_name.should == 'Main Type'
      end
    end
    
    context "when sub activity type assigned" do
      before do 
        @activity = Activity.gen(:activity_type => 
          ActivityType.gen(:name => 'Sub Type', :parent => 
            ActivityType.gen(:name => 'Main Type', :parent => nil))) 
        
      end
      it "should return the name" do
        @activity.full_type_name.should == 'Main Type -> Sub Type'
      end
    end
  end
end
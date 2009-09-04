require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Activity do
  it "should be created" do
    block_should(change(Activity, :count).by(1)) do
      Activity.make(:project => fx(:oranges_first_project), :user => fx(:stefan)).save.should be_true
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
    a = Activity.gen(:project => fx(:oranges_first_project), :user => fx(:jola), :minutes => 7.5 * 60)
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
    Activity.make(:project => fx(:oranges_first_project), :user => fx(:stefan), :date => Date.parse("2008-11-23")).save.should be_true
    Activity.is_activity_day(fx(:stefan), Date.parse("2008-11-23")).should be_true
  end
  
  describe "#notify_project_managers_about_saving method" do
    it "should send emails to project managers" do
      @activity = Activity.gen
      @kind_of_change = "updated"
      
      block_should change(Merb::Mailer.deliveries, :size).by(2) do
        @activity.notify_project_managers_about_saving(@kind_of_change)
      end
      
      deliveries = Merb::Mailer.deliveries[-2,2].map { |d| d.to }
      deliveries.should include([fx(:admin).email])
      deliveries.should include([fx(:koza).email])
    end
  end
  
  describe "#notify_project_managers_about_saving__if_enabled method" do
    before do
      @activity = Activity.gen
      @kind_of_change = "updated"
    end
    
    context "with notifications enabled" do
      before { Setting.get.update_attributes :enable_notifications => true }
      it "should call :notify_project_managers_about_saving" do
        @activity.should_receive(:notify_project_managers_about_saving).with(@kind_of_change)
        @activity.notify_project_managers_about_saving__if_enabled(@kind_of_change)
      end
    end
    
    context "with notifications disabled" do
      before { Setting.get.update_attributes :enable_notifications => false }
      it "should not call :notify_project_managers_about_saving" do
        @activity.should_not_receive(:notify_project_managers_about_saving).with(@kind_of_change)
        @activity.notify_project_managers_about_saving__if_enabled(@kind_of_change)
      end
    end
  end
  
  describe "after create observer" do
    before { @activity = Activity.make }
    
    context "if activity date is more than a day ago" do
      before { @activity.date = Date.today - 5 }
      
      it "should call :notify_project_managers_about_saving__if_enabled with 'created' argument" do
        @activity.should_receive(:notify_project_managers_about_saving__if_enabled).with('created')
        @activity.save
      end
    end
    
    context "if activity date is less than a day ago" do
      before { @activity.date = Date.today }
      
      it "should not call :notify_project_managers_about_saving__if_enabled" do
        @activity.should_not_receive(:notify_project_managers_about_saving__if_enabled)
        @activity.save
      end
    end
  end
  
  describe "after update observer" do
    before { @activity = Activity.gen }
    
    context "if activity date is more than a day ago" do
      before { @activity.date = Date.today - 5 }
      
      it "should call :notify_project_managers_about_saving__if_enabled with 'updated' argument" do
        @activity.should_receive(:notify_project_managers_about_saving__if_enabled).with('updated')
        @activity.save
      end
    end
    
    context "if activity date is less than a day ago" do
      before { @activity.date = Date.today }
      
      it "should not call :notify_project_managers_about_saving__if_enabled" do
        @activity.should_not_receive(:notify_project_managers_about_saving__if_enabled)
        @activity.save
      end
    end
  end

  describe "#price" do
    context "setter and getter (value in DB saved as integer)" do
      it "should return price based on assigned attribuand do not lose " do
        a = Activity.make()
        a.price = 1000000.11
        a.price.should == 1000000.11
        a.price.should be_a_kind_of BigDecimal
        a.reload.price.should == 1000000.11
      end
    end

    describe "getter" do

      context "when price is nil" do
        before { @activity = Activity.make(:price => nil) }

        context "when there is no corresponding hourly rate" do
          before { @activity.stub!(:hourly_rate => nil) }

          it "should return nil" do
            @activity.price.should == nil
          end
        end

        context "when there is corresponding hourly rate" do
          before { @activity.stub!(:hourly_rate => mock('hourly rate', :value => 37.50)) }

          it "should return its value" do
            @activity.price.should == 37.50
          end
        end
      end

    end
  end

  describe "#hourly_rate" do
    it "should return HourlyRate.find_for_activity result" do
      hr = HourlyRate.make
      HourlyRate.should_receive(:find_for_activity).and_return(hr)
      activity = Activity.make
      activity.hourly_rate.should == hr
    end
  end

end
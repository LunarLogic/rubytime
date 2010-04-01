require 'spec_helper'

describe Activity do
  it "should be created" do
    block_should(change(Activity, :count).by(1)) do
      Activity.prepare.save.should be_true
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

  context "marking as locked" do
    it "should not be locked when does not belong to invoice" do
      activity = Activity.generate
      activity.should_not be_locked
    end

    it "should not be locked when invoice is not locked" do
      invoice = Invoice.generate
      activity = Activity.generate :invoice => invoice
      activity.should_not be_locked
    end

    it "should be locked when invoice is locked" do
      invoice = Invoice.generate
      activity = Activity.generate :invoice => invoice
      invoice.issue!
      activity.should be_locked
    end
  end

  it "should find n recent activities" do
    time_travel_to(1.month.from_now) do
      10.times do |i|
        Activity.generate :date => Date.today - i, :comments => i.to_s
      end

      recent_activities = Activity.recent(3)
      recent_activities.should have(3).records
      recent_activities.map(&:comments).should == ['0', '1', '2']
    end
  end

  context "setting time" do
    it "should parse time correctly if proper hours value is set" do
      tests = {
        5      => 5 * 60,
        '6'    => 6 * 60,
        '7:15' => 7 * 60 + 15,
        ' 8.5' => 8.5 * 60,
        ' 8.9' => 8.9 * 60,
        '9,5'  => 9 * 60 + 30,
        '9.25'  => 9 * 60 + 15,
        24     => 24 * 60,
        '5h'   => 5 * 60,
        '0.5h'   => 30,
        '0,5h'   => 30,
        '7.5h'   => 7.5 * 60,
        '1.25h'  => 75,
        '40m'   => 40,
        '.5h'   => 0.5 * 60,
        '.75'   => 0.75 * 60
      }

      tests.each do |entry, result|
        a = Activity.new :hours => entry
        a.minutes.should == result
      end
    end

    it "should set an error if incorrect hours value is set" do
      tests = [25, '24:01', '1:80', 'jola', '5h30', '5:30h', '1.5m', '1000m']
      tests.each do |entry|
        a = Activity.new :hours => entry
        a.should_not be_valid
        a.minutes.should be_nil
        a.errors[:hours].should have(1).element
      end
    end

    it "should allow to set time using minutes field" do
      a = Activity.new :minutes => 123
      a.valid?
      a.errors[:hours].should be_blank
    end
  end

  context "formatting hours field" do
    it "should return formatted hours for saved activity" do
      a = Activity.prepare
      a.hours = "3,5"
      a.save!
      a = Activity.get(a.id) # it must be reloaded
      a.hours.should == "3:30"
    end

    it "should return entered hours for new activity" do
      a = Activity.new :hours => "3,5"
      a.hours.should == "3,5"
    end
  end

  describe "#for" do

    before :each do
      @employee = Employee.generate
    end

    it "should raise an ArgumentError when #for called with something else than :now or Hash with :year and :month" do
      tests = [
        :kiszonka,
        :nuwee,
        { :foo => "bar", :year => 123 },
        { :month => 2, :kiszka => "ki5zk4"},
        [:year, :month]
      ]
      tests.each do |arg|
        block_should(raise_argument_error) { @employee.activities.for(arg) }
      end
    end

    it "should raise an ArgumentError when #for called with :month not included in 1..12 or future year" do
      tests = [
        { :month => 0, :year => 2007 },
        { :month => 13, :year => 2004 },
        { :month => 10, :year => Date.today.year + 1 }
      ]
      tests.each do |date|
        block_should(raise_argument_error) { @employee.activities.for(date) }
      end
    end

    it "should return activities for given month" do
      today = Date.today
      beginning_of_month = Date.new(today.year, today.month, 1)
      end_of_last_month = beginning_of_month - 1
      last_month = end_of_last_month.month
      last_month_year = end_of_last_month.year
      beginning_of_last_month = Date.new(last_month_year, last_month, 1)

      last_month_count = 8
      this_month_count = 10

      last_month_count.times do |i|
        date = beginning_of_last_month + i
        activity = Activity.prepare :user => @employee, :date => date
        activity.save.should be_true
      end
      this_month_count.times do |i|
        date = beginning_of_month + i
        activity = Activity.prepare :user => @employee, :date => date
        activity.save.should be_true
      end

      @employee.reload
      @employee.activities.for(:this_month).count.should == this_month_count
      @employee.activities.for(:year => last_month_year, :month => last_month).count.should == last_month_count
    end

    it "should return activities for first and last day of month" do
      Activity.generate :user => @employee, :date => Date.parse("2008-11-01")
      Activity.generate :user => @employee, :date => Date.parse("2008-11-30")

      @employee.activities.for(:year => 2008, :month => 11).count.should == 2
    end
  end

  it "should be deletable by admin and by owner" do
    activity = Activity.generate
    admin = Employee.generate :admin
    other = Employee.generate

    activity.should be_deletable_by(activity.user)
    activity.should be_deletable_by(admin)
    activity.should_not be_deletable_by(other)
  end

  describe "#notify_project_managers" do
    it "should send emails to project managers" do
      @activity = Activity.generate
      manager_role = Role.first_or_generate :name => 'Project Manager'
      Employee.generate :role => manager_role
      managers = Employee.managers.all

      block_should change(Merb::Mailer.deliveries, :size).by(managers.length) do
        @activity.notify_project_managers(:updated)
      end

      included_emails = Merb::Mailer.deliveries.last(managers.length).map(&:to).flatten
      expected_emails = managers.map(&:email)
      included_emails.sort.should == expected_emails.sort
    end
  end

  describe "#notify_project_managers_if_enabled method" do
    before do
      @activity = Activity.generate
      @kind_of_change = "updated"
    end

    context "with notifications enabled" do
      before { Setting.get.update :enable_notifications => true }
      it "should call :notify_project_managers" do
        @activity.should_receive(:notify_project_managers).with(@kind_of_change)
        @activity.notify_project_managers_if_enabled(@kind_of_change)
      end
    end

    context "with notifications disabled" do
      before { Setting.get.update :enable_notifications => false }
      it "should not call :notify_project_managers" do
        @activity.should_not_receive(:notify_project_managers).with(@kind_of_change)
        @activity.notify_project_managers_if_enabled(@kind_of_change)
      end
    end
  end

  describe "after create observer" do
    before { @activity = Activity.prepare }

    context "if activity date is more than a day ago" do
      before { @activity.date = Date.today - 5 }

      it "should call :notify_project_managers_if_enabled with 'created' argument" do
        @activity.should_receive(:notify_project_managers_if_enabled).with(:created)
        @activity.save
      end
    end

    context "if activity date is less than a day ago" do
      before { @activity.date = Date.today }

      it "should not call :notify_project_managers_if_enabled" do
        @activity.should_not_receive(:notify_project_managers_if_enabled)
        @activity.save
      end
    end
  end

  describe "after update observer" do
    before { @activity = Activity.generate }

    context "if activity date is more than a day ago" do
      before { @activity.date = Date.today - 5 }

      it "should call :notify_project_managers_if_enabled with 'updated' argument" do
        @activity.should_receive(:notify_project_managers_if_enabled).with(:updated)
        @activity.save
      end
    end

    context "if activity date is less than a day ago" do
      before { @activity.date = Date.today }

      it "should not call :notify_project_managers_if_enabled" do
        @activity.should_not_receive(:notify_project_managers_if_enabled)
        @activity.save
      end
    end
  end

  describe "#price_frozen?" do
    it "should be true if :price_value and :price_currency are not nil and are saved" do
      activity = Activity.generate :price_value => 10.99, :price_currency => Currency.generate
      activity.price_frozen?.should be_true
    end

    it "should be false if :price_value or :price_currency is nil" do
      activity = Activity.generate :price_value => nil, :price_currency => Currency.generate
      activity.price_frozen?.should be_false

      activity = Activity.generate :price_value => 10.99, :price_currency => nil
      activity.price_frozen?.should be_false
    end
  end

  describe "#freeze_price!" do
    context "if price is already frozen" do
      before do 
        @activity = Activity.generate :price_value => 10.99, :price_currency => Currency.generate
        @activity.price_frozen?.should be_true
      end

      it "should raise an Exception" do
        block_should(raise_error(Exception)) { @activity.freeze_price! }
      end
    end

    context "if price is not frozen" do
      before do 
        @activity = Activity.generate :price_value => nil, :price_currency => nil, :minutes => 30
        @activity.price_frozen?.should be_false
      end

      context "if there is corresponding hourly rate" do
        before do
          @money = Money.new(12.89, Currency.first_or_generate)
          @hourly_rate = mock('hourly rate')
          @hourly_rate.should_receive(:*).with(0.5).at_least(:once).and_return(@money)
          @activity.stub!(:hourly_rate => @hourly_rate)
        end

        it "should calculate price based on hourly_rate and save it" do
          @activity.freeze_price!
          @activity.reload
          @activity.price.should == @money
        end

        it "should round money values to 2 decimal digits" do
          @money.value = 20.0 / 7.0
          block_should_not(raise_error) do
            @activity.freeze_price!
            @activity.price_value.should == 2.86
          end
        end
      end

      context "if there is no corresponding hourly rate" do
        before do
          @activity.stub!(:hourly_rate => nil)
        end

        it "should raise an Exception" do
          block_should(raise_error(Exception)) { @activity.freeze_price! }
        end
      end
    end
  end

  describe "#price" do
    context "if :price_value and :price_currency are both not nil" do
      it "should return Money object with proper values" do
        @currency = Currency.first_or_generate
        @activity = Activity.prepare :price_value => 10.99, :price_currency => @currency
        @activity.price.should be_instance_of(Money)
        @activity.price.value.should == 10.99
        @activity.price.currency.should == @currency
      end
    end

    context "if any of :price_value and :price_currency is nil" do
      before { @activity = Activity.prepare(:price_value => nil, :price_currency => nil, :minutes => 90 ) }

      context "if there is corresponding hourly rate" do
        it "should return Money object with properly computed values" do
          @currency = Currency.first_or_generate
          @activity.stub! :hourly_rate => mock('hourly rate', :* => Money.new(15.60, @currency))
          @activity.price.should be_instance_of(Money)
          @activity.price.value.should == 15.60
          @activity.price.currency.should == @currency
        end
      end

      it "should round money values to 2 decimal digits" do
        @currency = Currency.first_or_generate
        @activity.stub! :hourly_rate => mock('hourly rate', :* => Money.new(8.0 / 3.0, @currency))
        @activity.price.should be_instance_of(Money)
        @activity.price.value.should == 2.67
        @activity.price.currency.should == @currency
      end

      context "if there is no corresponding hourly rate" do
        it "should return nil" do
          @activity.stub! :hourly_rate => nil
          @activity.price.should be_nil
        end
      end
    end
  end

  describe "#price=" do
    before :each do
      @activity = Activity.prepare :price_value => 10.99, :price_currency => Currency.generate
    end

    context "if called with nil" do
      it "should clear :price_value and :price_currency fields" do
        @activity.price = nil
        @activity.price_value.should be_nil
        @activity.price_currency.should be_nil
      end
    end

    context "if called with Money object" do
      it "should set :price_value and :price_currency fields" do
        euro = Currency.generate
        @activity.price = Money.new(8.59, euro)
        @activity.price_value.should == 8.59
        @activity.price_currency.should == euro
      end
    end

    it "should round money values to 2 decimal digits" do
      euro = Currency.first_or_generate
      @activity.price = Money.new(4.0 / 3.0, euro)
      @activity.price_value.should == 1.33
      @activity.price_currency.should == euro
    end
  end

  describe "#hourly_rate" do
    it "should return HourlyRate.find_for_activity result" do
      hr = HourlyRate.prepare
      HourlyRate.should_receive(:find_for_activity).and_return(hr)
      activity = Activity.prepare
      activity.hourly_rate.should == hr
    end
  end

  describe "#duration=" do
    before { @activity = Activity.prepare }

    it "should set :minutes attribute to a correct value when called with a number" do
      @activity.duration = 1.hour + 15.minutes
      @activity.minutes.should == 75
    end

    it "should set :minutes attribute to nil when called with nil" do
      @activity.duration = nil
      @activity.minutes.should be_nil
    end
  end

  describe "#duration" do
    before { @activity = Activity.prepare }

    it "should return a number when :minutes is not nil" do
      @activity.minutes = 10
      @activity.duration.should == 10.minutes
    end

    it "should return nil when :minutes is nil" do
      @activity.minutes = nil
      @activity.duration.should be_nil
    end
  end

  describe "new record" do
    before { @activity = Activity.prepare }

    it "should not be valid when there is no corresponding hourly rate" do
      @activity.stub! :hourly_rate => nil
      @activity.should_not be_valid
      @activity.errors.on(:hourly_rate).should_not be_blank
    end

    it "should be valid when there is a corresponding hourly rate" do
      @rate = HourlyRate.first_or_generate(
        :project => @activity.project,
        :role => @activity.user.role,
        :takes_effect_at => @activity.date
      )
      @activity.stub! :hourly_rate => @rate
      @activity.should be_valid
      @activity.errors.on(:hourly_rate).should be_blank
    end
  end

  describe "existing record" do
    before { @activity = Activity.generate }

    it "should be invalid when there is no corresponding hourly rate" do
      @activity.stub! :hourly_rate => nil
      @activity.should_not be_valid
    end
  end

  it "should check if activity exist for date" do
    user = Employee.generate
    Activity.prepare(:user => user, :date => date("2008-11-23")).save.should be_true
    Activity.is_activity_day(user, date("2008-11-23")).should be_true
  end

  describe "main- and sub- activity_type_id setters" do
    before do
      @activity_type_A  = ActivityType.generate
      @activity_type_B  = ActivityType.generate
      @activity_type_B1 = ActivityType.generate :parent => @activity_type_B
      @activity_type_B2 = ActivityType.generate :parent => @activity_type_B
      
      @activity = Activity.generate
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
      @activity_type_A  = ActivityType.generate
      @activity_type_B  = ActivityType.generate
      @activity_type_B1 = ActivityType.generate :parent => @activity_type_B
      @activity_type_B2 = ActivityType.generate :parent => @activity_type_B
      
      @activity = Activity.generate
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
  
  describe "#breadcrumb_name" do
    context "when no activity type assigned" do
      before { @activity = Activity.generate :activity_type => nil }
      it "should return nil" do
        @activity.breadcrumb_name.should be_nil
      end
    end
    
    context "when an activity type assigned" do
      before do 
        @activity_type = ActivityType.generate
        @activity_type.stub!(:breadcrumb_name => 'The breadcrumb name')
        @activity = Activity.generate :activity_type => @activity_type
      end
      it "should return the name" do
        @activity.breadcrumb_name.should == 'The breadcrumb name'
      end
    end
  end
  
  describe "#custom_properties= and #custom_properties" do
    before do
      @custom_property_AAA = ActivityCustomProperty.generate :name => "AAA"
      @custom_property_BBB = ActivityCustomProperty.generate :name => "BBB"
      @custom_property_CCC = ActivityCustomProperty.generate :name => "CCC"
      
      @activity = Activity.gen
    end
    
    it "should assign only properties with not-blank values" do
      @activity.custom_properties = { @custom_property_BBB.id.to_s => "125", @custom_property_CCC.id.to_s => "" }
      @activity.custom_properties.should == { @custom_property_BBB.id => 125 }
    end
    
    describe "with save operation following" do
      before do
        @activity.activity_custom_property_values.create(:activity_custom_property => @custom_property_AAA, :value => 12)
        @activity.activity_custom_property_values.create(:activity_custom_property => @custom_property_CCC, :value => 45)
        
        @activity.custom_properties = { 
          @custom_property_AAA.id.to_s => "15", 
          @custom_property_BBB.id.to_s => "125", 
          @custom_property_CCC.id.to_s => "" }
          
        @activity.save
      end
      
      it "should update custom value for changed value" do
        @activity.activity_custom_property_values.first(:activity_custom_property_id => @custom_property_AAA.id).should_not be_nil
        @activity.custom_properties[@custom_property_AAA.id].should == 15
      end
      
      it "should create new custom value for new value" do
        @activity.activity_custom_property_values.first(:activity_custom_property_id => @custom_property_BBB.id).should_not be_nil
        @activity.custom_properties[@custom_property_BBB.id].should == 125
      end
      
      it "should remove custom value for blank value" do
        @activity.activity_custom_property_values.first(:activity_custom_property_id => @custom_property_CCC.id).should be_nil
        @activity.custom_properties[@custom_property_CCC.id].should == nil
      end
    end
    
  end
  
  describe "#destroy" do
    before do
      @activity = Activity.generate
      @activity.activity_custom_property_values.create(
        :activity_custom_property => ActivityCustomProperty.generate,
        :value => 12
      )
      @activity.activity_custom_property_values.create(
        :activity_custom_property => ActivityCustomProperty.generate,
        :value => 45
      )
    end
    
    it "should destroy assigned custom property values" do
      @activity.activity_custom_property_values.count.should > 0
      @activity.destroy
      @activity.activity_custom_property_values.count.should == 0
    end
  end
  
  context "without required custom property" do
    before do
      @custom_property = ActivityCustomProperty.generate(:name => "AAA", :required => true)
      
      @activity = Activity.generate
      @activity.activity_custom_property_values.count.should == 0
    end
    
    it { @activity.should have_errors_on(:activity_custom_property_values) }
  end
  
  describe ".custom_property_values_sum" do
    before do
      @custom_property_AAA = ActivityCustomProperty.generate(:name => "AAA")
      @custom_property_BBB = ActivityCustomProperty.generate(:name => "BBB")
      
      @activities = [
        Activity.generate(:custom_properties => { @custom_property_AAA.id => 10.05 }),
        Activity.generate(:custom_properties => { @custom_property_AAA.id =>  5.03, @custom_property_BBB.id => 120 }),
        Activity.generate(:custom_properties => { @custom_property_AAA.id =>  1.00, @custom_property_BBB.id =>  17 })
      ]
    end
    
    it "should return the sum of given custom property values" do
      Activity.custom_property_values_sum(@activities, @custom_property_AAA).to_s.should == 16.08.to_s
      Activity.custom_property_values_sum(@activities, @custom_property_BBB).should == 137
    end
  end

end

require 'spec_helper'

describe Activity do
  it "should be created" do
    block_should(change(Activity, :count).by(1)) do
      Activity.prepare.save.should be_true
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
        24     => 24 * 60
      }

      tests.each do |entry, result|
        a = Activity.new :hours => entry
        a.minutes.should == result
      end
    end

    it "should set an error if incorrect hours value is set" do
      tests = [25, '24:01', '1:80', 'jola']
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

  describe "#notify_project_managers_about_saving" do
    it "should send emails to project managers" do
      @activity = Activity.generate
      manager_role = Role.first_or_generate :name => 'Project Manager'
      Employee.generate :role => manager_role
      managers = Employee.managers.all

      block_should change(Merb::Mailer.deliveries, :size).by(managers.length) do
        @activity.notify_project_managers_about_saving("updated")
      end

      included_emails = Merb::Mailer.deliveries.last(managers.length).map(&:to).flatten
      expected_emails = managers.map(&:email)
      included_emails.sort.should == expected_emails.sort
    end
  end

  describe "#notify_project_managers_about_saving__if_enabled method" do
    before do
      @activity = Activity.generate
      @kind_of_change = "updated"
    end

    context "with notifications enabled" do
      before { Setting.get.update :enable_notifications => true }
      it "should call :notify_project_managers_about_saving" do
        @activity.should_receive(:notify_project_managers_about_saving).with(@kind_of_change)
        @activity.notify_project_managers_about_saving__if_enabled(@kind_of_change)
      end
    end

    context "with notifications disabled" do
      before { Setting.get.update :enable_notifications => false }
      it "should not call :notify_project_managers_about_saving" do
        @activity.should_not_receive(:notify_project_managers_about_saving).with(@kind_of_change)
        @activity.notify_project_managers_about_saving__if_enabled(@kind_of_change)
      end
    end
  end

  describe "after create observer" do
    before { @activity = Activity.prepare }

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
    before { @activity = Activity.generate }

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

        it "should set price to nil and save that" do
          @activity.freeze_price!
          @activity.reload
          @activity.price.should be_nil
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

    it "should be valid even when there is no corresponding hourly rate" do
      @activity.stub! :hourly_rate => nil
      @activity.should be_valid
      @activity.errors.on(:hourly_rate).should be_nil
    end
  end

end

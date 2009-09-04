require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe HourlyRateLog do
  
  context "with empty :logged_at" do
    before { @hourly_rate_log = HourlyRateLog.make(:logged_at => nil) }
    
    it "should be valid" do
      @hourly_rate_log.should be_valid
    end
    
    it "should set it to the current date and time" do
      @time_before = DateTime.now
      @hourly_rate_log.save
      @time_after = DateTime.now
      
      @hourly_rate_log.logged_at.should >= @time_before
      @hourly_rate_log.logged_at.should <= @time_after
    end
  end
  
  context "with empty :operation_type" do
    before { @hourly_rate_log = HourlyRateLog.make(:operation_type => nil) }
    
    it "should not be valid" do
      @hourly_rate_log.should_not be_valid
      @hourly_rate_log.errors.on(:operation_type).should_not be_empty
    end
  end
  
  context "with invalid :operation_type" do
    before { @hourly_rate_log = HourlyRateLog.make(:operation_type => 'invalid operation type') }
    
    it "should not be valid" do
      @hourly_rate_log.should_not be_valid
      @hourly_rate_log.errors.on(:operation_type).should_not be_empty
    end
  end
  
  context "with empty :operation_author" do
    before { @hourly_rate_log = HourlyRateLog.make(:operation_author => nil) }
    
    it "should not be valid" do
      @hourly_rate_log.should_not be_valid
      @hourly_rate_log.errors.on(:operation_author_id).should_not be_empty
    end
  end
  
  context "without :hourly_rate assigned" do
    before { @hourly_rate_log = HourlyRateLog.make(:hourly_rate => nil) }
    
    it "should not be valid" do
      @hourly_rate_log.should_not be_valid
      @hourly_rate_log.errors.on(:hr_id).should_not be_empty
    end
  end
  
  context "#hourly_rate= setter" do
    before do
      @hourly_rate = HourlyRate.make
      @hourly_rate_log = HourlyRateLog.new :hourly_rate => @hourly_rate
    end
    
    it "should populate hr_ attributes" do
      @hourly_rate_log.hr_id.should                      == @hourly_rate.id
      @hourly_rate_log.hr_project_id.should              == @hourly_rate.project_id
      @hourly_rate_log.hr_role_id.should                 == @hourly_rate.role_id
      @hourly_rate_log.hr_takes_effect_at.should         == @hourly_rate.takes_effect_at
      @hourly_rate_log.hr_value.should                   == @hourly_rate.value
      @hourly_rate_log.hr_currency.should                == @hourly_rate.currency
    end
  end
  
  context "with :operation_type == 'destroy'" do
    before { @hourly_rate_log = HourlyRateLog.make(:operation_type => 'destroy') }
    
    context "after saving" do
      before { @hourly_rate_log.save }
      
      it "after save should null all hr_ attributes except :hr_id" do
        @hourly_rate_log.hr_id.should_not                  be_nil
        @hourly_rate_log.hr_project_id.should              be_nil
        @hourly_rate_log.hr_role_id.should                 be_nil
        @hourly_rate_log.hr_takes_effect_at.should         be_nil
        @hourly_rate_log.hr_value.should                   be_nil
        @hourly_rate_log.hr_currency.should                be_nil
      end
    end
  end

end
require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe HourlyRate do
  
  before { HourlyRate.all.destroy! }

  describe ":value accessor" do
    it "should work with numbers" do
      HourlyRate.gen :value => 567.89
      HourlyRate.first.value.should == 567.89
    end
    
    it "should work with empty string" do
      hourly_rate = HourlyRate.make :value => ''
      hourly_rate.value.should == nil
    end
    
    it "should work with nil" do
      hourly_rate = HourlyRate.make :value => nil
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
    hourly_rate = HourlyRate.make(:project => nil)
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:project_id).should_not be_empty
  end
  
  it "should not allow to save record without :role assigned" do
    hourly_rate = HourlyRate.make(:role => nil)
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:role_id).should_not be_empty
  end
  
  it "should not allow to save record without :takes_effect_at" do
    hourly_rate = HourlyRate.make(:takes_effect_at => '')
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:takes_effect_at).should_not be_empty
  end
  
  it "should not allow to save record without :value" do
    hourly_rate = HourlyRate.make(:value => '')
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:value).should_not be_empty
  end
  
  it "should not allow to save record without :currency" do
    hourly_rate = HourlyRate.make(:currency => nil)
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:currency_id).should_not be_empty
  end
  
  it "should not allow to save record with the same set of :project, :role and :takes_effect_at" do
    attributes = { :project => fx(:oranges_first_project), :role => fx(:developer), :takes_effect_at => Date.today }
    
    hourly_rate = HourlyRate.make(attributes)
    duplicated_hourly_rate = HourlyRate.make(attributes)
    
    hourly_rate.save.should be_true
    duplicated_hourly_rate.save.should be_false
    duplicated_hourly_rate.errors.on(:takes_effect_at).should_not be_empty
  end
  
  it "should not allow to save record without :operation_author assigned" do
    hourly_rate = HourlyRate.make(:operation_author => nil)
    hourly_rate.save.should be_false
    hourly_rate.errors.on(:operation_author).should_not be_empty
  end
  
  it "should have default order by :takes_effect_at" do
    hr1 = HourlyRate.gen(:takes_effect_at => Date.today - 2)
    hr2 = HourlyRate.gen(:takes_effect_at => Date.today    )
    hr3 = HourlyRate.gen(:takes_effect_at => Date.today - 4)

    HourlyRate.all.should == [hr3, hr1, hr2]
  end

  it "should return HourlyRate object for specified activity " do 
    hr1 = HourlyRate.gen(:takes_effect_at => Date.parse("2009-09-01"))
    hr2 = HourlyRate.gen(:takes_effect_at => Date.parse("2009-08-01"), :project => hr1.project, :role => hr1.role)
    [hr1.role_id, hr1.project_id].should == [hr2.role_id, hr2.project_id]
    u = hr1.role.employees.first
    u.should be_a_kind_of User
    a = Activity.new(:project => hr1.project, :user => u, :date => Date.parse("2009-08-02"))
    hr = HourlyRate.find_for_activity(a)
    hr.should be_a_kind_of(HourlyRate)
    hr.should == hr2
  end
  
  describe "#to_money" do
    before { @hourly_rate = HourlyRate.gen :value => 44.88, :currency => fx(:euro) }
    
    it "should return Money object" do
      @hourly_rate.to_money.should be_instance_of(Money)
    end
    
    it "should return proper Money object" do
      @hourly_rate.to_money.should == Money.new(44.88, fx(:euro))
    end
  end
  
  describe "#*" do
    before { @hourly_rate = HourlyRate.gen :value => 44.88, :currency => fx(:euro) }
    
    it "should return Money object" do
      (@hourly_rate * 0.5).should be_instance_of(Money)
    end
    
    it "should return properly calculated Money object" do
      (@hourly_rate * 0.5).should == Money.new(22.44, fx(:euro))
    end
  end
end
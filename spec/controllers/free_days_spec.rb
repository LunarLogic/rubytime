require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe FreeDays do
  
  describe ".index" do
    
    it "should be successful" do
      FreeDay.stub!(:to_ical => "iCalFileContent")
      dispatch_to(FreeDays, :index).should be_successful
    end
    
    it "should render free days iCalendar" do
      FreeDay.should_receive(:to_ical).and_return("iCalFileContent")
      dispatch_to(FreeDays, :index).body.should == "iCalFileContent"
    end

  end

  describe "#new" do

    it "should add new vacation day" do
      employee = Employee.gen(:role => fx(:developer))
      controller = as(employee).dispatch_to(FreeDays, :new, :date => "2009-05-01", :user_id => employee.id)
      controller.should be_successful
    end

    it "should not add new vacation day" do
      employee = Employee.gen(:role => fx(:developer))
      controller = as(employee).dispatch_to(FreeDays, :new, :date => "333333333333", :user_id => employee.id)
      controller.status.should == 400
    end

  end


  describe "#delete" do

    it "should delete a vacation flag from free day" do
      employee = Employee.gen(:role => fx(:developer))
      controller = as(employee).dispatch_to(FreeDays, :new, :date => "2009-05-01", :user_id => employee.id)
      controller.should be_successful
      
      controller2 = as(employee).dispatch_to(FreeDays, :delete, :date => "2009-05-01", :user_id => employee.id)
      controller2.should be_successful

    end
    
    it "should not delete a vacation flag form working day" do
      employee = Employee.gen(:role => fx(:developer))
      employee2 = Employee.gen(:role => fx(:developer))

      controller = as(employee).dispatch_to(FreeDays, :new, :date => "2009-05-01", :user_id => employee.id)
      controller.should be_successful
      
      controller2 = as(employee).dispatch_to(FreeDays, :delete, :date => "2009-06-01", :user_id => employee.id)
      controller2.status.should == 400

      controller3 = as(employee).dispatch_to(FreeDays, :delete, :date => "333333333333", :user_id => employee.id)
      controller3.status.should == 400

      controller4 = as(employee).dispatch_to(FreeDays, :delete, :date => "2009-06-01", :user_id => employee2.id)
      controller4.status.should == 400

      controller5 = as(employee).dispatch_to(FreeDays, :delete, :date => "2009-05-01", :user_id => employee.id)
      controller5.should be_successful

    end


  end


end
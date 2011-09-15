require 'spec_helper'

describe FreeDaysController do
  describe ".index" do
    before { Setting.stub!(:free_days_access_key => 'access_key') }

    context "with valid :access_key" do
      it "should be successful" do
        FreeDay.stub! :to_ical => "iCalFileContent"
        dispatch_to(FreeDays, :index, :access_key => 'access_key').should be_successful
      end

      it "should render free days iCalendar" do
        FreeDay.should_receive(:to_ical).and_return("iCalFileContent")
        dispatch_to(FreeDays, :index, :access_key => 'access_key').body.should == "iCalFileContent"
      end
    end

    context "with invalid :access_key" do
      it "should return an error" do
        block_should(raise_forbidden) { dispatch_to(FreeDays, :index, :access_key => 'invalid') }
      end
    end
  end

  describe "#create" do
    it "should add new vacation day if date is correct" do
      employee = Employee.generate
      controller = as(employee).dispatch_to(FreeDays, :create, :date => "2009-05-01", :user_id => employee.id)
      controller.should be_successful
    end

    it "should not add new vacation day if date is incorrect" do
      employee = Employee.generate
      controller = as(employee).dispatch_to(FreeDays, :create, :date => "333333333333", :user_id => employee.id)
      controller.status.should == 400
    end

    it "should add free day for current user by default" do
      employee = Employee.generate
      response = as(employee).dispatch_to(FreeDays, :create, :date => '2009-05-01')
      FreeDay.last.date.should == Date.parse('2009-05-01')
      FreeDay.last.user.should == employee
    end

    it "should let admin add free days for other users" do
      employee = Employee.generate
      response = as(:admin).dispatch_to(FreeDays, :create, :date => '2009-05-01', :user_id => employee.id)
      FreeDay.last.user.should == employee
    end

    it "should not let users add free days for other users" do
      employee1 = Employee.generate
      employee2 = Employee.generate
      response = as(employee1).dispatch_to(FreeDays, :create, :date => '2009-05-01', :user_id => employee2.id)
      FreeDay.last.user.should == employee1
    end

  end

  describe "#delete" do
    it "should delete a vacation flag from free day" do
      employee = Employee.generate
      controller = as(employee).dispatch_to(FreeDays, :create, :date => "2009-05-01", :user_id => employee.id)
      controller.should be_successful

      controller2 = as(employee).dispatch_to(FreeDays, :delete, :date => "2009-05-01", :user_id => employee.id)
      controller2.should be_successful
    end

    it "should not delete a vacation flag from working day" do
      employee = Employee.generate
      employee2 = Employee.generate

      controller = as(employee).dispatch_to(FreeDays, :create, :date => "2009-05-01", :user_id => employee.id)
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

    describe "permissions" do
      before :each do
        @employee = Employee.generate
        FreeDay.generate :date => '2009-05-01', :user => @employee
      end

      it "should remove free day for current user by default" do
        block_should(change(@employee.free_days, :count).by(-1)) do
          response = as(@employee).dispatch_to(FreeDays, :delete, :date => '2009-05-01')
        end
      end

      it "should let admin remove free days for other users" do
        block_should(change(@employee.free_days, :count).by(-1)) do
          response = as(:admin).dispatch_to(FreeDays, :delete, :date => '2009-05-01', :user_id => @employee.id)
        end
      end

      it "should not let users remove free days for other users" do
        block_should_not(change(@employee.free_days, :count)) do
          response = as(:employee).dispatch_to(FreeDays, :delete, :date => '2009-05-01', :user_id => @employee.id)
        end
      end
    end

  end

end

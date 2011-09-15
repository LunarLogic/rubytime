require 'spec_helper'

describe FreeDaysController do
  describe "GET 'index'" do
    before(:each) do
      Setting.stub!(:free_days_access_key => 'access_key')
    end

    context "with valid :access_key" do
      it "should be successful" do
        FreeDay.stub! :to_ical => "iCalFileContent"
        get(:index, :access_key => 'access_key', :format => "ics").should be_successful
      end

      it "should render free days iCalendar" do
        FreeDay.should_receive(:to_ical).and_return("iCalFileContent")
        get(:index, :access_key => 'access_key', :format => "ics").body.should == "iCalFileContent"
      end
    end

    context "with invalid :access_key" do
      it "should return an error" do
        get(:index, :access_key => 'invalid', :format => "ics").status.should == 403
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @employee = Employee.generate
    end

    context "as employee" do
      before(:each) do
        login(@employee)
      end

      it "should add new vacation day if date is correct" do
        post(:create, :date => "2009-05-01", :user_id => @employee.id).should be_successful
      end

      it "should not add new vacation day if date is incorrect" do
        post(:create, :date => "333333333333", :user_id => @employee.id).status.should == 400
      end

      it "should add free day for current user by default" do
        post(:create, :date => '2009-05-01')
        FreeDay.last.date.should == Date.parse('2009-05-01')
        FreeDay.last.user.should == @employee
      end
    end

    context "as admin" do
      login(:admin)

      it "should let admin add free days for other users" do
        post(:create, :date => '2009-05-01', :user_id => @employee.id).should be_successful
        FreeDay.last.user.should == @employee
      end
    end

    context "as another user" do
      login(:employee)

      it "should not let users add free days for other users" do
        post(:create, :date => '2009-05-01', :user_id => @employee.id)
        FreeDay.last.user.should_not == @employee
        FreeDay.last.user.should == @current_user
      end
    end
  end

  describe "DELETE 'delete'" do
    context "as employee" do
      before(:each) do
        @employee = Employee.generate
        login(@employee)
      end

      it "should delete a vacation flag from free day" do
        post(:create, :date => "2009-05-01", :user_id => @employee.id).should be_successful
        delete(:delete, :date => "2009-05-01", :user_id => @employee.id).should be_successful
      end

      it "should not delete a vacation flag from working day" do
        employee2 = Employee.generate

        post(:create, :date => "2009-05-01", :user_id => @employee.id).should be_successful
        delete(:delete, :date => "2009-06-01", :user_id => @employee.id).status.should == 400
        delete(:delete, :date => "333333333333", :user_id => @employee.id).status.should == 400
        delete(:delete, :date => "2009-06-01", :user_id => employee2.id).status.should == 400
        delete(:delete, :date => "2009-05-01", :user_id => @employee.id).should be_successful
      end
    end

    describe "permissions" do
      before :each do
        @employee = Employee.generate
        FreeDay.generate :date => '2009-05-01', :user => @employee
      end

      it "should remove free day for current user by default" do
        login(@employee)
        block_should(change(@employee.free_days, :count).by(-1)) do
          delete(:delete, :date => '2009-05-01')
        end
      end

      it "should let admin remove free days for other users" do
        login(:admin)
        block_should(change(@employee.free_days, :count).by(-1)) do
          delete(:delete, :date => '2009-05-01', :user_id => @employee.id)
        end
      end

      it "should not let users remove free days for other users" do
        login(:employee)
        block_should_not(change(@employee.free_days, :count)) do
          delete(:delete, :date => '2009-05-01', :user_id => @employee.id)
        end
      end
    end
  end
end

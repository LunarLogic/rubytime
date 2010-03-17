require 'spec_helper'

describe HourlyRates do

  it "should refuse to perform any action for guest, non-pm employee and client's user" do
    [:index, :create, :update, :destroy].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(HourlyRates, action) }
      block_should(raise_forbidden) { as(:employee).dispatch_to(HourlyRates, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(HourlyRates, action) }
    end
  end

  describe "#index" do
    it "should return hourly rates grouped by roles" do
      HourlyRate.all.destroy!
      Project.all.destroy!
      Role.all.destroy!

      devs = Role.generate :name => 'Devs'
      testers = Role.generate :name => 'Testers'
      managers = Role.generate :name => 'Managers'

      admin = Employee.generate :admin, :role => managers
      project = Project.generate

      rates = [
        # devs have 1, testers have 2, managers haven't got any
        HourlyRate.generate(:takes_effect_at => Date.today - 10, :project => project, :role => devs),
        HourlyRate.generate(:takes_effect_at => Date.today - 8,  :project => project, :role => testers),
        HourlyRate.generate(:takes_effect_at => Date.today - 6,  :project => project, :role => testers)
      ]
      rates.each { |rate| rate.date_format_for_json = admin.date_format }

      response = as(admin).dispatch_to(HourlyRates, :index, :project_id => project.id)
      response.should be_successful
      response.body.should == [
        { :project_id => project.id, :role_id => devs.id,     :role_name => 'Devs',     :hourly_rates => [rates[0]] },
        { :project_id => project.id, :role_id => managers.id, :role_name => 'Managers', :hourly_rates => [] },
        { :project_id => project.id, :role_id => testers.id,  :role_name => 'Testers',  :hourly_rates => rates[1..2] }
      ].to_json
    end
  end

  describe "#create" do

    it "should make new record with given attributes and attempt to save it" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :date_format_for_json= => nil)
      HourlyRate.should_receive(:new).with('these' => 'attrs').and_return(@hourly_rate)
      @hourly_rate.should_receive(:save).and_return(true)

      @response = as(:admin).dispatch_to(HourlyRates, :create, :hourly_rate => { :these => :attrs })
    end

    it "should set :operation_author attr of the record" do
      admin = Employee.generate :admin
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :save => true, :date_format_for_json= => nil)
      HourlyRate.should_receive(:new).with('these' => 'attrs').and_return(@hourly_rate)
      @hourly_rate.should_receive(:operation_author=).with(admin)

      as(admin).dispatch_to(HourlyRates, :create, :hourly_rate => { :these => :attrs })
    end

    context "if record created successfully" do
      before :each do
        @hourly_rate = mock('hourly rate',
          :operation_author= => nil,
          :save => true,
          :date_format_for_json= => nil,
          :to_json => 'json attributes'.to_json
        )
        HourlyRate.stub! :new => @hourly_rate
        @request = lambda do
          @response = as(:admin).dispatch_to(HourlyRates, :create, :hourly_rate => { :these => :attrs })
        end
      end

      it "should respond successfully" do
        @request.call
        @response.should be_successful
      end

      it "should set :date_format_for_json of the record" do
        @hourly_rate.should_receive(:date_format_for_json=)
        @request.call
      end

      it "should return json with status :ok and record attributes" do
        @request.call
        @response.body.should == { :status => :ok, :hourly_rate => 'json attributes' }.to_json
      end
    end

    context "if record creation failed" do
      before :each do
        @hourly_rate = mock('hourly rate',
          :operation_author= => nil,
          :save => false,
          :error_messages => 'Error messages'
        )
        HourlyRate.stub! :new => @hourly_rate
        @response = as(:admin).dispatch_to(HourlyRates, :create)
      end

      it "should respond successfully" do
        @response.should be_successful
      end

      it "should return json with status :invalid and error messages" do
        @response.body.should == {
          :status => :invalid,
          :hourly_rate => { :error_messages => 'Error messages' }
        }.to_json
      end
    end
  end

  describe "#update" do
    
    it "should look for the record of given id" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :update => true, :date_format_for_json= => nil)
      HourlyRate.should_receive(:get).with('39').and_return(@hourly_rate)

      @response = as(:admin).dispatch_to(HourlyRates, :update, :id => 39)
    end

    context "if record of given :id existed" do

      it "should set :operation_author attr of the record" do
        admin = Employee.generate :admin
        @hourly_rate = mock('hourly rate', :update => true, :date_format_for_json= => nil)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:operation_author=).with(admin)

        as(admin).dispatch_to(HourlyRates, :update, :id => 39, :hourly_rate => { :these => :attrs })
      end

      it "should attempt to update it with given attributes" do
        @hourly_rate = mock('hourly rate', :operation_author= => nil, :date_format_for_json= => nil)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:update).with('these' => 'attrs').and_return(true)

        @response = as(:admin).dispatch_to(HourlyRates, :update, :id => 39, :hourly_rate => { :these => :attrs })
      end

      context "and was successfully updated" do
        before :each do
          @hourly_rate = mock('hourly rate',
            :operation_author= => nil,
            :update => true,
            :date_format_for_json= => nil,
            :to_json => 'json attributes'.to_json
          )
          HourlyRate.stub! :get => @hourly_rate
          @request = lambda do
            @response = as(:admin).dispatch_to(HourlyRates, :update, :hourly_rate => { :these => :attrs })
          end
        end

        it "should respond successfully" do
          @request.call
          @response.should be_successful
        end

        it "should set :date_format_for_json of the record" do
          @hourly_rate.should_receive(:date_format_for_json=)
          @request.call
        end

        it "should return json with status :ok and record attributes" do
          @request.call
          @response.body.should == { :status => :ok, :hourly_rate => 'json attributes' }.to_json
        end
      end

      context "and its update failed" do
        before :each do
          @hourly_rate = mock('hourly rate',
            :operation_author= => nil,
            :update => false,
            :error_messages => 'Error messages'
          )
          HourlyRate.stub! :get => @hourly_rate
          @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :update) }
        end

        it "should respond successfully" do
          @request.call
          @response.should be_successful
        end

        it "should return json with status :invalid and error messages" do
          @request.call
          @response.body.should == {
            :status => :invalid,
            :hourly_rate => { :error_messages => 'Error messages' }
          }.to_json
        end
      end
    end

    context "if record of given :id didn't exist" do
      it "should raise NotFound error" do
        HourlyRate.stub! :get => nil
        block_should(raise_not_found) { as(:admin).dispatch_to(HourlyRates, :update, :id => 39) }
      end
    end
  end

  describe "#destroy" do

    it "should look for the record of given id" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :destroy => true)
      HourlyRate.should_receive(:get).with('39').and_return(@hourly_rate)

      @response = as(:admin).dispatch_to(HourlyRates, :destroy, :id => 39)
    end

    context "when record of given :id existed" do

      it "should set :operation_author attr of the record" do
        admin = Employee.generate :admin
        @hourly_rate = mock('hourly rate', :destroy => true)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:operation_author=).with(admin)

        as(admin).dispatch_to(HourlyRates, :destroy, :id => 39)
      end

      it "should attempt to destroy it" do
        @hourly_rate = mock('hourly rate', :operation_author= => nil)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:destroy).and_return(true)

        @response = as(:admin).dispatch_to(HourlyRates, :destroy, :id => 39)
      end

      context "and was successfully destroyed" do
        before :each do
          @hourly_rate = mock('hourly rate', :operation_author= => nil, :destroy => true)
          HourlyRate.stub! :get => @hourly_rate
          @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :destroy) }
        end

        it "should respond successfully" do
          @request.call
          @response.should be_successful
        end

        it "should return json with status :ok and record attributes" do
          @request.call
          @response.body.should == { :status => :ok }.to_json
        end
      end

      context "and couldn't be destroyed" do
        before :each do
          @hourly_rate = mock('hourly rate',
            :operation_author= => nil,
            :destroy => false,
            :error_messages => 'Cannot destroy'
          )
          HourlyRate.stub! :get => @hourly_rate
          @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :destroy) }
        end

        it "should return json with status :error and error messages" do
          @request.call
          @response.body.should == {
            :status => :error,
            :hourly_rate => { :error_messages => 'Cannot destroy' }
          }.to_json
        end
      end
    end

    context "when record of given :id didn't exist" do
      it "should raise NotFound error" do
        HourlyRate.stub! :get => nil
        block_should(raise_not_found) { as(:admin).dispatch_to(HourlyRates, :destroy, :id => 39) }
      end
    end
  end

end

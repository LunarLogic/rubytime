require 'spec_helper'

describe HourlyRatesController do

  context "as guest" do
    before(:each) do
      @hourly_rate = HourlyRate.generate
    end
    login(:guest)

    it "should ask to login" do
      get(:index).                              should redirect_to(new_user_session_path)
      post(:create).                            should redirect_to(new_user_session_path)
      put(:update, :id => @hourly_rate.id).     should redirect_to(new_user_session_path)
      delete(:destroy, :id => @hourly_rate.id). should redirect_to(new_user_session_path)
    end
  end

  context "as non-admin user" do
    before(:each) do
      @hourly_rate = HourlyRate.generate
    end

    it "should refuse to perform any action" do
      [:employee, :client].each do |user|
        login(user)

        get(:index).                              status.should == 403
        post(:create).                            status.should == 403
        put(:update, :id => @hourly_rate.id).     status.should == 403
        delete(:destroy, :id => @hourly_rate.id). status.should == 403
      end
    end
  end

  describe "GET 'index'" do
    login(:admin)

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

      get(:index, :project_id => project.id, :format => :json)
      response.should be_successful
      response.body.should == [
        { :project_id => project.id, :role_id => devs.id,     :role_name => 'Devs',     :hourly_rates => [rates[0]] },
        { :project_id => project.id, :role_id => managers.id, :role_name => 'Managers', :hourly_rates => [] },
        { :project_id => project.id, :role_id => testers.id,  :role_name => 'Testers',  :hourly_rates => rates[1..2] }
      ].to_json
    end
  end

  describe "POST 'create'" do
    login(:admin)

    it "should make new record with given attributes and attempt to save it" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil,
                          :date_format_for_json= => nil, :to_json => "", :as_json => "".as_json)
      HourlyRate.should_receive(:new).with('these' => 'attrs').and_return(@hourly_rate)
      @hourly_rate.should_receive(:save).and_return(true)

      post(:create, :hourly_rate => { 'these' => 'attrs' })
    end

    it "should set :operation_author attr of the record" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :save => true,
                          :date_format_for_json= => nil, :to_json => "", :as_json => "".as_json)
      HourlyRate.should_receive(:new).with('these' => 'attrs').and_return(@hourly_rate)
      @hourly_rate.should_receive(:operation_author=).with(@current_user)

      post(:create, :hourly_rate => { 'these' => 'attrs' })
    end

    context "if record created successfully" do
      before :each do
        @hourly_rate = mock('hourly rate',
                            :operation_author= => nil,
                            :save => true,
                            :date_format_for_json= => nil,
                            :to_json => 'json attributes'.to_json,
                            :as_json => 'json attributes'.as_json)
        HourlyRate.stub! :new => @hourly_rate
      end

      it "should respond successfully" do
        post(:create, :hourly_rate => { :these => :attrs })
        response.should be_successful
      end

      it "should set :date_format_for_json of the record" do
        @hourly_rate.should_receive(:date_format_for_json=)
        post(:create, :hourly_rate => { :these => :attrs })
      end

      it "should return json with status :ok and record attributes" do
        post(:create, :hourly_rate => { :these => :attrs })
        response.body.to_s.should == 
          { :status => :ok, :hourly_rate => 'json attributes'}.to_json
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
        post(:create)
      end

      it "should respond successfully" do
        response.should be_successful
      end

      it "should return json with status :invalid and error messages" do
        response.body.should == {
          :status => :invalid,
          :hourly_rate => { :error_messages => 'Error messages' }
        }.to_json
      end
    end
  end

  describe "PUT 'update'" do
    login(:admin)
    
    it "should look for the record of given id" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil,
                          :update => true, :date_format_for_json= => nil,
                          :to_json => "", :as_json => "".as_json)
      HourlyRate.should_receive(:get).with('39').and_return(@hourly_rate)

      put(:update, :id => '39')
    end

    context "if record of given :id existed" do

      it "should set :operation_author attr of the record" do
        @hourly_rate = mock('hourly rate', :update => true,
                            :date_format_for_json= => nil, :as_json => "".as_json)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:operation_author=).with(@current_user)

        put(:update, :id => 39, :hourly_rate => { :these => :attrs })
      end

      it "should attempt to update it with given attributes" do
        @hourly_rate = mock('hourly rate', :operation_author= => nil,
                            :date_format_for_json= => nil, :as_json => "".as_json)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:update).with('these' => 'attrs').and_return(true)

        put(:update, :id => 39, :hourly_rate => { "these" => "attrs" })
      end

      context "and was successfully updated" do
        before :each do
          @hourly_rate = mock('hourly rate',
                              :operation_author= => nil,
                              :update => true,
                              :date_format_for_json= => nil,
                              :to_json => 'json attributes'.to_json,
                              :as_json => 'json attributes'.as_json)
          HourlyRate.stub! :get => @hourly_rate
        end

        it "should respond successfully" do
          put(:update, :id => "39", :hourly_rate => { :these => :attrs })
          @response.should be_successful
        end

        it "should set :date_format_for_json of the record" do
          @hourly_rate.should_receive(:date_format_for_json=)
          put(:update, :id => "39", :hourly_rate => { :these => :attrs })
        end

        it "should return json with status :ok and record attributes" do
          put(:update, :id => "39", :hourly_rate => { :these => :attrs })
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
          put(:update, :id => "39")
        end

        it "should respond successfully" do
          response.should be_successful
        end

        it "should return json with status :invalid and error messages" do
          response.body.should == {
            :status => :invalid,
            :hourly_rate => { :error_messages => 'Error messages' }
          }.to_json
        end
      end
    end

    context "if record of given :id didn't exist" do
      it "should raise NotFound error" do
        HourlyRate.stub! :get => nil
        put(:update, :id => 39).status.should == 404
      end
    end
  end

  describe "DELETE 'destroy'" do
    login(:admin)

    it "should look for the record of given id" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :destroy => true)
      HourlyRate.should_receive(:get).with('39').and_return(@hourly_rate)

      delete(:destroy, :id => "39")
    end

    context "when record of given :id existed" do

      it "should set :operation_author attr of the record" do
        @hourly_rate = mock('hourly rate', :destroy => true)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:operation_author=).with(@current_user)

        delete(:destroy, :id => 39)
      end

      it "should attempt to destroy it" do
        @hourly_rate = mock('hourly rate', :operation_author= => nil)
        HourlyRate.stub! :get => @hourly_rate
        @hourly_rate.should_receive(:destroy).and_return(true)

        delete(:destroy, :id => 39)
      end

      context "and was successfully destroyed" do
        before :each do
          @hourly_rate = mock('hourly rate', :operation_author= => nil, :destroy => true)
          HourlyRate.stub! :get => @hourly_rate
          delete(:destroy, :id => "39")
        end

        it "should respond successfully" do
          response.should be_successful
        end

        it "should return json with status :ok and record attributes" do
          response.body.should == { :status => :ok }.to_json
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
          delete(:destroy, :id => "39")
        end

        it "should return json with status :error and error messages" do
          response.body.should == {
            :status => :error,
            :hourly_rate => { :error_messages => 'Cannot destroy' }
          }.to_json
        end
      end
    end

    context "when record of given :id didn't exist" do
      it "should raise NotFound error" do
        HourlyRate.stub! :get => nil
        delete(:destroy, :id => 39).status.should == 404
      end
    end
  end

end

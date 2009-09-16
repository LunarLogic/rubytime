require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a hourly_rate exists" do
  HourlyRate.all.destroy!
  request(resource(:hourly_rates), :method => "POST", 
    :params => { :hourly_rate => { :id => nil }})
end

describe HourlyRates do
  
  it "should refuse to perform any action for guest, non-pm employee and client's user" do
    [:index, :create, :update, :destroy].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(HourlyRates, action) }
      block_should(raise_forbidden) { as(fx(:jola)).dispatch_to(HourlyRates, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(HourlyRates, action) }
    end
  end
  
  describe "#index" do
    before(:each) do
      HourlyRate.all.destroy!
      
      @hourly_rates = [
        HourlyRate.gen(:takes_effect_at => Date.today - 10, :project => fx(:oranges_first_project), :role => fx(:developer)),
        HourlyRate.gen(:takes_effect_at => Date.today - 8, :project => fx(:oranges_first_project), :role => fx(:tester)),
        HourlyRate.gen(:takes_effect_at => Date.today - 6, :project => fx(:oranges_first_project), :role => fx(:tester))
      ]
      @response = as(:admin).dispatch_to(HourlyRates, :index, :project_id => fx(:oranges_first_project).id)
      
      @hourly_rates.each { |hourly_rate| hourly_rate.date_format_for_json = fx(:admin).date_format }
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should return hourly rates grouped by roles" do
      @response.body.should == [
        {:project_id => fx(:oranges_first_project).id, :role_id => fx(:developer).id,       :role_name => 'Developer',       :hourly_rates => [@hourly_rates[0]] },
        {:project_id => fx(:oranges_first_project).id, :role_id => fx(:project_manager).id, :role_name => 'Project Manager', :hourly_rates => [] },
        {:project_id => fx(:oranges_first_project).id, :role_id => fx(:tester).id,          :role_name => 'Tester',          :hourly_rates => [@hourly_rates[1], @hourly_rates[2]] }
      ].to_json
    end
  end
  
  describe "#create" do
    
    it "should make new record with given attributes and attempt to save it" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :date_format_for_json= => nil)
      HourlyRate.should_receive(:new).with({'these' => 'attrs'}).and_return(@hourly_rate)
      @hourly_rate.should_receive(:save).and_return(true)
      
      @response = as(:admin).dispatch_to(HourlyRates, :create, :hourly_rate => {:these => :attrs})
    end
    
    it "should set :operation_author attr of the record" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :save => true, :date_format_for_json= => nil)
      HourlyRate.should_receive(:new).with({'these' => 'attrs'}).and_return(@hourly_rate)
      @hourly_rate.should_receive(:operation_author=).with(fx(:admin))
      
      as(fx(:admin)).dispatch_to(HourlyRates, :create, :hourly_rate => {:these => :attrs})
    end
    
    context "if record created successfully" do
      before(:each) do
        HourlyRate.stub!(:new => @hourly_rate = mock('hourly rate', :operation_author= => nil, :save => true, :date_format_for_json= => nil, :to_json => 'json attributes'.to_json))
        @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :create, :hourly_rate => {:these => :attrs}) }
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
      before(:each) do
        HourlyRate.stub!(:new => @hourly_rate = mock('hourly rate', :operation_author= => nil, :save => false, :error_messages => 'Error messages'))
        @response = as(:admin).dispatch_to(HourlyRates, :create)
      end
      
      it "should respond successfully" do
        @response.should be_successful
      end
      
      it "should return json with status :invalid and error messages" do
        @response.body.should == { :status => :invalid, :hourly_rate => { :error_messages => 'Error messages' } }.to_json
      end
    end
  end
  
  describe "#update" do
    
    it "should look for the record of given id" do
      @hourly_rate = mock('hourly rate', :operation_author= => nil, :update_attributes => true, :date_format_for_json= => nil)
      HourlyRate.should_receive(:get).with('39').and_return(@hourly_rate)
      
      @response = as(:admin).dispatch_to(HourlyRates, :update, :id => 39)
    end
    
    context "if record of given :id existed" do
      
      it "should set :operation_author attr of the record" do
        HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :update_attributes => true, :date_format_for_json= => nil))
        @hourly_rate.should_receive(:operation_author=).with(fx(:admin))
      
        as(:admin).dispatch_to(HourlyRates, :update, :id => 39, :hourly_rate => {:these => :attrs})
      end
      
      it "should attempt to update it with given attributes" do
        HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :operation_author= => nil, :date_format_for_json= => nil))
        @hourly_rate.should_receive(:update_attributes).with({'these' => 'attrs'}).and_return(true)
      
        @response = as(:admin).dispatch_to(HourlyRates, :update, :id => 39, :hourly_rate => {:these => :attrs})
      end
    
      context "and was successfully updated" do
        before(:each) do
          HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :operation_author= => nil, :update_attributes => true, :date_format_for_json= => nil, :to_json => 'json attributes'.to_json))
          @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :update, :hourly_rate => {:these => :attrs}) }
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
        before(:each) do
          HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :operation_author= => nil, :update_attributes => false, :error_messages => 'Error messages'))
          @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :update) }
        end
      
        it "should respond successfully" do
          @request.call
          @response.should be_successful
        end
      
        it "should return json with status :invalid and error messages" do
          @request.call
          @response.body.should == { :status => :invalid, :hourly_rate => { :error_messages => 'Error messages' } }.to_json
        end
      end
    end
    
    context "if record of given :id didn't exist" do
      it "should raise NotFound error" do
        HourlyRate.stub!(:get => nil)
        lambda { as(:admin).dispatch_to(HourlyRates, :update, :id => 39) }.should raise_error(Merb::ControllerExceptions::NotFound)
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
        HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :destroy => true))
        @hourly_rate.should_receive(:operation_author=).with(fx(:admin))

        as(:admin).dispatch_to(HourlyRates, :destroy, :id => 39)
      end
      
      it "should attempt to destroy it" do
        HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :operation_author= => nil))
        @hourly_rate.should_receive(:destroy).and_return(true)

        @response = as(:admin).dispatch_to(HourlyRates, :destroy, :id => 39)
      end
    
      context "and was successfully destroyed" do
        before(:each) do
          HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :operation_author= => nil, :destroy => true))
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
        before(:each) do
          HourlyRate.stub!(:get => @hourly_rate = mock('hourly rate', :operation_author= => nil, :destroy => false, :error_messages => 'Cannot destroy'))
          @request = lambda { @response = as(:admin).dispatch_to(HourlyRates, :destroy) }
        end
      
        it "should return json with status :error and error messages" do
          @request.call
          @response.body.should == { :status => :error, :hourly_rate => { :error_messages => 'Cannot destroy' } }.to_json
        end
      end
    end
    
    context "when record of given :id didn't exist" do
      it "should raise NotFound error" do
        HourlyRate.stub!(:get => nil)
        lambda { as(:admin).dispatch_to(HourlyRates, :destroy, :id => 39) }.should raise_error(Merb::ControllerExceptions::NotFound)
      end
    end
  end
  
end

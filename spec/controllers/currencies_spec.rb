require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Currencies do
  
  it "should refuse to perform any action for guest, non-pm employee and client's user" do
    [:index, :create, :destroy].each do |action|
      block_should(raise_unauthenticated) { as(:guest).dispatch_to(Currencies, action) }
      block_should(raise_forbidden) { as(fx(:jola)).dispatch_to(Currencies, action) }
      block_should(raise_forbidden) { as(:client).dispatch_to(Currencies, action) }
    end
  end
  
  describe "#index" do
    before(:each) do
      @response = as(:admin).dispatch_to(Currencies, :index)
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should put all currencies into @currencies" do
      @response.assigns(:currencies).should == Currency.all
    end
    
    it "should put a new instance to @currency" do
      @response.assigns(:currency).should be_instance_of(Currency)
      @response.assigns(:currency).should be_new_record
    end
  end
  
  describe "#create" do
    
    it "should make new record with given attributes and attempt to save it" do
      @currency = mock('currency')
      Currency.should_receive(:new).with({'these' => 'attrs'}).and_return(@currency)
      @currency.should_receive(:save).and_return(true)
      
      @response = as(:admin).dispatch_to(Currencies, :create, :currency => {:these => :attrs})
    end
    
    context "if record created successfully" do
      before(:each) do
        Currency.stub!(:new => @currency = mock('currency', :save => true))
        @request = lambda { @response = as(:admin).dispatch_to(Currencies, :create, :currency => {:these => :attrs}) }
      end
      
      it "should redirect to :currencies" do
        @request.call
        @response.should redirect_to(resource(:currencies))
      end
      
    end
    
    context "if record creation failed" do
      before(:each) do
        @currency = Currency.new 
        @currency.stub!(:save => false)
        
        Currency.stub!(:new => @currency)
        @response = as(:admin).dispatch_to(Currencies, :create)
      end
      
      it "should respond successfully" do
        @response.should be_successful
      end
    end
  end
  
  describe "#destroy" do
    
    it "should look for the record of given id" do
      @currency = mock('currency', :destroy => true)
      Currency.should_receive(:get).with('39').and_return(@currency)
      
      @response = as(:admin).dispatch_to(Currencies, :destroy, :id => 39)
    end
    
    context "when record of given :id existed" do
      
      it "should attempt to destroy it" do
        Currency.stub!(:get => @currency = mock('currency'))
        @currency.should_receive(:destroy).and_return(true)
  
        @response = as(:admin).dispatch_to(Currencies, :destroy, :id => 39)
      end
    
      context "and was successfully destroyed" do
        before(:each) do
          Currency.stub!(:get => @currency = mock('currency', :destroy => true))
          @request = lambda { @response = as(:admin).dispatch_to(Currencies, :destroy) }
        end
      
        it "should respond successfully" do
          @request.call
          @response.should be_successful
        end
      end
    
      context "and couldn't be destroyed" do
        before(:each) do
          Currency.stub!(:get => @currency = mock('currency', :destroy => false))
          @request = lambda { @response = as(:admin).dispatch_to(Currencies, :destroy) }
        end
      
        it "should not respond successfully" do
          @request.call
          @response.should_not be_successful
        end
      end
    end
    
    context "when record of given :id didn't exist" do
      it "should raise NotFound error" do
        Currency.stub!(:get => nil)
        lambda { as(:admin).dispatch_to(Currencies, :destroy, :id => 39) }.should raise_error(Merb::ControllerExceptions::NotFound)
      end
    end
  end
  
end

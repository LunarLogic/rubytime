require 'spec_helper'

describe CurrenciesController do

  before(:each) do
    @currency = Currency.generate
  end

  it "should ask guest to login on all actions" do
    login(:guest)

    get(:index)
    response.should redirect_to new_user_session_path

    post(:create)
    response.should redirect_to new_user_session_path

    delete(:destroy, :id => @currency.id)
    response.should redirect_to new_user_session_path
  end

  it "should refuse to perform any action for non-admins" do
    [:employee, :client].each do |user|
      login(user)
      get(:index).                           status.should == 403
      post(:create).                         status.should == 403
      delete(:destroy, :id => @currency.id). status.should == 403
    end
  end

  context "as admin" do
    login(:admin)

    describe "GET 'index'" do
      before :each do
        3.times { Currency.generate }
        get(:index)
      end
      
      it "should respond successfully" do
        response.should be_successful
      end
      
      it "should put all currencies into @currencies" do
        assigns(:currencies).should == Currency.all
      end
      
      it "should put a new instance to @currency" do
        assigns(:currency).should be_instance_of(Currency)
        assigns(:currency).should be_new_record
      end
    end
  
    describe "POST 'create'" do
      it "should make new record with given attributes and attempt to save it" do
        @currency = mock('currency')
        Currency.should_receive(:new).with('these' => 'attrs').and_return(@currency)
        @currency.should_receive(:save).and_return(true)

        post(:create, :currency => { "these" => "attrs" })
      end

      context "if record created successfully" do
        before :each do
          @currency = mock('currency', :save => true)
          Currency.stub! :new => @currency
        end

        it "should redirect to :currencies" do
          post(:create, :currency => { "these" => "attrs" })
          response.should redirect_to(currencies_path)
        end
      end

      context "if record creation failed" do
        before :each do
          @currency = Currency.new 
          @currency.stub! :save => false

          Currency.stub! :new => @currency
          post(:create)
        end

        it "should respond successfully" do
          @response.should be_successful
        end
      end
    end

    describe "GET 'edit'" do
      it "should show currency edit form" do
        get(:edit, :id => @currency.id).should be_successful
      end
    end

    describe "POST 'update'" do
      it "should update the currency" do
        put(:update, :id => @currency.id, :currency => {:plural_name => 'Silver coins'})

        response.should redirect_to(currencies_path)
        @currency.reload.plural_name.should == 'Silver coins'
      end
    end

    describe "DELETE 'destroy'" do

      it "should look for the record of given id" do
        @currency = mock('currency', :destroy => true)
        Currency.should_receive(:get).with('39').and_return(@currency)

        delete(:destroy, :id => "39")
      end

      context "when record of given :id existed" do

        it "should attempt to destroy it" do
          @currency = mock('currency')
          Currency.stub! :get => @currency
          @currency.should_receive(:destroy).and_return(true)

          delete(:destroy, :id => "39")
        end

        context "and was successfully destroyed" do
          before :each do
            @currency = mock('currency', :destroy => true)
            Currency.stub! :get => @currency
          end

          it "should respond successfully" do
            delete(:destroy, :id => "39")
            response.should be_successful
          end
        end

        context "and couldn't be destroyed" do
          before :each do
            @currency = mock('currency', :destroy => false)
            Currency.stub! :get => @currency
          end

          it "should not respond successfully" do
            delete(:destroy, :id => "39")
            response.should_not be_successful
          end
        end
      end

      context "when record of given :id didn't exist" do
        it "should set not found status" do
          expect { delete(:destroy, :id => "no such id") }.to raise_error(DataMapper::ObjectNotFoundError)
        end
      end
    end
  end
end

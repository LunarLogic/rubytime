require 'spec_helper'

describe Currency do

  context "with empty :singular_name" do
    before { @currency = Currency.make(:singular_name => '') }
    
    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:singular_name).should_not be_empty
    end
  end
  
  context "with :singular_name that already exists" do
    before do 
      @original_currency = Currency.gen(:singular_name => 'this singular name is now taken')
      @currency = Currency.make(:singular_name => @original_currency.singular_name)
    end
    
    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:singular_name).should_not be_empty
    end
  end
  
  context "with empty :plural_name" do
    before { @currency = Currency.make(:plural_name => '') }
    
    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:plural_name).should_not be_empty
    end
  end
  
  context "with :plural_name that already exists" do
    before do 
      @original_currency = Currency.gen(:plural_name => 'this plural name is now taken')
      @currency = Currency.make(:plural_name => @original_currency.plural_name)
    end
    
    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:plural_name).should_not be_empty
    end
  end
  
  context "with empty :prefix" do
    before { @currency = Currency.make(:prefix => '') }
    
    it "should be valid" do
      @currency.should be_valid
      @currency.errors.on(:prefix).should be_nil
    end
  end
  
  context "with :prefix that contains digits" do
    before { @currency = Currency.make(:prefix => '34') }
    
    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:prefix).should_not be_empty
    end
  end
  
  context "with empty :suffix" do
    before { @currency = Currency.make(:suffix => '') }
    
    it "should be valid" do
      @currency.should be_valid
      @currency.errors.on(:suffix).should be_nil
    end
  end
  
  context "with :suffix that contains digits" do
    before { @currency = Currency.make(:suffix => '34') }
    
    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:suffix).should_not be_empty
    end
  end
  
  describe "#render" do
    before { @currency = Currency.make(:prefix => 'PREFIX', :suffix => 'SUFFIX') }
    
    it "should return rendered value with prefix and suffix" do
      @currency.render(12.34).should == 'PREFIX12.34SUFFIX'
    end
  end

end
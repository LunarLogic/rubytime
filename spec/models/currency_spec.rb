require 'spec_helper'

describe Currency do

  context "with empty :singular_name" do
    before { @currency = Currency.prepare(:singular_name => '') }

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:singular_name).should_not be_empty
    end
  end

  context "with :singular_name that already exists" do
    before do 
      @original_currency = Currency.generate
      @currency = Currency.prepare :singular_name => @original_currency.singular_name
    end

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:singular_name).should_not be_empty
    end
  end

  context "with :singular_name that has invalid format" do
    before do 
      @currency1 = Currency.prepare :singular_name => '333,333'
      @currency2 = Currency.prepare :singular_name => '333'
      @currency3 = Currency.prepare :singular_name => '...'
    end

    it "should not be valid" do
      [@currency1,@currency2,@currency3].each { |c| c.should_not be_valid }
      [@currency1,@currency2,@currency3].each { |c| c.errors.on(:singular_name).should_not be_empty }
    end
  end

  context "with empty :plural_name" do
    before { @currency = Currency.prepare(:plural_name => '') }

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:plural_name).should_not be_empty
    end
  end

  context "with :plural_name that already exists" do
    before do 
      @original_currency = Currency.generate
      @currency = Currency.prepare(:plural_name => @original_currency.plural_name)
    end

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:plural_name).should_not be_empty
    end
  end

  context "with :plural_name that has invalid format" do
    before do 
      @currency = Currency.prepare :plural_name => '333,333'
    end

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:plural_name).should_not be_empty
    end
  end

  context "with empty :prefix" do
    before { @currency = Currency.prepare(:prefix => '') }

    it "should be valid" do
      @currency.should be_valid
      @currency.errors.on(:prefix).should be_nil
    end
  end

  context "with :prefix that contains digits" do
    before { @currency = Currency.prepare(:prefix => '34') }

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:prefix).should_not be_empty
    end
  end

  context "with empty :suffix" do
    before { @currency = Currency.prepare(:suffix => '') }

    it "should be valid" do
      @currency.should be_valid
      @currency.errors.on(:suffix).should be_nil
    end
  end

  context "with :suffix that contains digits" do
    before { @currency = Currency.prepare(:suffix => '34') }

    it "should not be valid" do
      @currency.should_not be_valid
      @currency.errors.on(:suffix).should_not be_empty
    end
  end

  describe "#render" do
    before { @currency = Currency.prepare(:prefix => 'PREFIX', :suffix => 'SUFFIX') }

    it "should return rendered value with prefix and suffix" do
      @currency.render(12.34).should == 'PREFIX12.34SUFFIX'
    end
  end

end

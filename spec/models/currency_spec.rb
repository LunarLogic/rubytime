# -*- coding: utf-8 -*-
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

  context "with :singular_name" do
    before do 
      @valid_currencies = ["Zaïre","Złoty","Nuevo Peso"]
    end

    it "should be valid" do
      @valid_currencies.each do |c|
        @currency = Currency.prepare(:singular_name => c)
        @currency.should be_valid
        @currency.errors.should be_empty
      end
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

  context "with :plural_name" do
    before do 
      @valid_currencies = ["Zaïre","Złoty","Nuevo Peso"]
    end

    it "should be valid" do
      @valid_currencies.each do |c|
        @currency = Currency.prepare(:plural_name => c)
        @currency.should be_valid
        @currency.errors.should be_empty
      end
    end
  end

  context "with empty :prefix" do
    before { @currency = Currency.prepare(:prefix => '') }

    it "should be valid" do
      @currency.should be_valid
      @currency.errors.on(:prefix).should be_nil
    end
  end

  context "with empty :suffix" do
    before { @currency = Currency.prepare(:suffix => '') }

    it "should be valid" do
      @currency.should be_valid
      @currency.errors.on(:suffix).should be_nil
    end
  end

  describe "#render" do
    before { @currency = Currency.prepare(:prefix => 'PREFIX', :suffix => 'SUFFIX') }

    it "should return rendered value with prefix and suffix" do
      @currency.render(12.34).should == 'PREFIX12.34SUFFIX'
    end
  end

end

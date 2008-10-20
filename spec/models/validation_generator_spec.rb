require File.join( File.dirname(__FILE__), '..', "spec_helper" )


describe Rubytime::ValidationGenerator do
  before(:all) do
    class President
      include DataMapper::Resource
      include Rubytime::ValidationGenerator
      
      # can't test with String fields since String adds implicit length validation
      property :first_name, Text
      property :last_name,  Text
      property :age,        Integer
      property :email,      String, :format => :email, :allow_nil => true
      
      validates_present :first_name
      validates_present :age
      validates_length :last_name, :min => 5, :max => 25
    end
  end

  it "should add validation_info method to class which included it" do
    President.respond_to?(:validation_info).should be_true
  end
  
  it "should return validation info as hash" do
    President.validation_info.should be_kind_of(Hash)
  end
  
  it "should return hash like { :rules  => instace_of_array1, :messages => instace_of_array2 }" do
    President.validation_info.size.should == 2
    President.validation_info[:rules].should be_kind_of(Array)
    President.validation_info[:messages].should be_kind_of(Array)
  end

  describe "#validation_info[:rules]" do
    before(:all) do
      @rules = President.validation_info[:rules]
    end

    it "should have hashes with size >= 1" do
      @rules.each do |rule| 
        rule.should be_kind_of(Hash)
        rule.size.should >= 1
      end
    end
    
    it "should include a hash with keys equal to validates fields" do
      validates_fields = [:first_name, :last_name, :age]
      
      # @rules.size.should == validates_fields.size
      
      validates_fields.each do |field|
        @rules.any? { |rule| rule.has_key?(field) }.should be_true
      end
    end

    it "should generate 'required' validation for each field validated with validates_present or :nullable => false" do
      rule_for(:first_name)[:required].should be_true
      rule_for(:age)[:required].should be_true
    end
    
    it "should generate minlength for fields validated with validates_length and :min" do
      rule_for(:last_name).size.should == 3
      rule_for(:last_name)[:required].should be_true
      rule_for(:last_name)[:minlength].should == 5
      rule_for(:last_name)[:maxlength].should == 25
    end
    
    def rule_for(field_name)
      @rules.find { |rule| rule.has_key? field_name }[field_name]
    end
  end
end
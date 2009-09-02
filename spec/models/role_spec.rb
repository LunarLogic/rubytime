require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Role do
  
  describe ":can_manage_financial_data attribute" do
    it "should have default value false" do
      Role.new.can_manage_financial_data.should == false
    end
  end
  
  context "with empty :can_manage_financial_data" do
    before { @role = Role.make(:can_manage_financial_data => nil) }
    
    it "should not be valid" do
      @role.should_not be_valid
      @role.errors.on(:can_manage_financial_data).should_not be_empty
    end
  end

end
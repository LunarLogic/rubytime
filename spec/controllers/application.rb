require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Application do

  it "should include AuthenticatedSystem" do
    Application.included_modules.include?(Utype::AuthenticatedSystem).should be(true)
  end

end
require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  before(:all) { Client.all.destroy!; Project.all.destroy! }
  
  it "should be created" do
    lambda { Project.make.save.should be_true }.should change(Project, :count).by(1)
  end
end

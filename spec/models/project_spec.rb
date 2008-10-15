require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  before(:all) { Client.all.destroy!; Project.all.destroy! }
  
  it "should be created" do
    lambda { Project.make.save.should be_true }.should change(Project, :count).by(1)
  end
  
  it "should find active projects" do
    3.times { Project.gen }
    2.times { Project.gen(:active => false) }
    Project.count.should == 5
    Project.active.count.should == 3
  end
end

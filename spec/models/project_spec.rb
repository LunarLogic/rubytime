require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Project do
  it "should be created" do
    block_should(change(Project, :count).by(1)) do
      Project.make(:client => fx(:orange)).save.should be_true
    end
  end
  
  it "should find active projects" do
    Project.count.should == 9
    Project.active.count.should == 7
  end
end

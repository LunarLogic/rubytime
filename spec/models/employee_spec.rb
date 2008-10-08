require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Employee do

  it "should be created" do
    employee = Employee.make
    lambda { employee.save }.should change(Employee, :count).by(1)
    employee.role.should == :developer
  end

  it "should be created as tester" do
    employee = Employee.gen(:role => :tester)
    employee.role.should == :tester
  end

  it "should not be created if has invalid role" do
    employee = Employee.make(:role => :invalid)
    employee.save.should be_false
    employee.errors.on(:role).size.should == 1
  end
end
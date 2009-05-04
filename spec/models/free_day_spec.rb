require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe FreeDay do

  it "should be created" do
    block_should(change(FreeDay, :count).by(1)) do
      FreeDay.make(:user => fx(:koza)).save.should be_true
    end
  end

  it "should be created correctly" do
    FreeDay.make(:user => fx(:koza), :date => Date.parse("2009-11-30")).save.should be_true
    FreeDay.is_day_off(fx(:koza).id, Date.parse("2009-11-30")).should be_true
  end


end
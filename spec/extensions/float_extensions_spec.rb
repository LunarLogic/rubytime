require 'spec_helper'

describe Float do
  
  it 'should round itself to 2 decimal places' do
    1.55.round_to_2_digits.should == 1.55
    1.0.round_to_2_digits.should == 1.0
    29.23456.round_to_2_digits.should == 29.23
    29.23556.round_to_2_digits.should == 29.24
    (2.0/3).round_to_2_digits.should == 0.67
    -567.876.round_to_2_digits.should == -567.88
  end
  
end

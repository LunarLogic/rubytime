require 'spec_helper'

describe String, '#generate_random' do
  
  it 'should return random string of given size made of original string content' do
    "abcd"  .generate_random( 1).should =~ /^[abcd]$/
    "abcd"  .generate_random( 3).should =~ /^[abcd]{3}$/
    "123ABC".generate_random(10).should =~ /^[123ABC]{10}$/
  end
  
end

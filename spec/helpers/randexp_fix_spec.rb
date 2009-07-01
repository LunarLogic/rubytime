require "spec"

describe Randexp::Dictionary do
  before(:each) do
    @old_path = Randexp::Dictionary.dict_path
    Randexp::Dictionary.dict_path = nil
  end

  after(:each) do
    Randexp::Dictionary.dict_path = @old_path
  end

  it "should read files from a system file if dict_path is not set (and that file is present)" do
    mock_file_exists_with_contents("/usr/share/dict/words", "aaa\nbbb\nccc\n")

    Randexp::Dictionary.load_dictionary.should == ["aaa", "bbb", "ccc"]
  end

  it "should read files from dict_path if it is set and present" do
    mock_file_exists_with_contents("local_file", "aaa\nbbb\nccc\n")

    Randexp::Dictionary.dict_path = "local_file"    
    Randexp::Dictionary.load_dictionary.should == ["aaa", "bbb", "ccc"]
  end

  it "should reread files every time dict_path is set" do
    mock_file_exists_with_contents("file1", "aaa")
    mock_file_exists_with_contents("file2", "bbb")
    mock_file_exists_with_contents("/usr/share/dict/words", "ccc")

    Randexp::Dictionary.dict_path = "file1"
    Randexp::Dictionary.load_dictionary.should == ["aaa"]

    Randexp::Dictionary.dict_path = "file2"
    Randexp::Dictionary.load_dictionary.should == ["bbb"]

    Randexp::Dictionary.dict_path = nil
    Randexp::Dictionary.load_dictionary.should == ["ccc"]
  end

  it "should read the dict file only once" do
    mock_file_exists_with_contents("file1", "aaa") # also checks that the file is read exactly once

    Randexp::Dictionary.dict_path = "file1"
    3.times { Randexp::Dictionary.load_dictionary.should == ["aaa"] }    
  end

  protected
  def mock_file_exists_with_contents(name, contents)
    File.should_receive(:exists?).with(name).at_least(:once).and_return(true)
    File.should_receive(:read).with(name).at_least(:once).and_return(contents)
  end  
end
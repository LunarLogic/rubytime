require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Setting do
  
  before { Setting.all.destroy! }
  
  describe '.enable_notifications method' do
    
    context 'when a Setting record exists' do
      before { @setting = Setting.create! }
      it 'should return the value of the setting'  do
        Setting.first.update_attributes :enable_notifications => true
        Setting.enable_notifications.should == true
      end
    end
    
    context 'when no Setting record exists' do
      it 'should create a Setting record' do
        expect{Setting.enable_notifications}.to change{Setting.count}.by(1)
      end
      
      it 'should return the value of the setting'  do
        Setting.enable_notifications.should == Setting.properties[:enable_notifications].default
      end
    end
  end

end
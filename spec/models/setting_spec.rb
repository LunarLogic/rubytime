require 'spec_helper'

describe Setting do

  before { Setting.all.destroy! }

  describe '.enable_notifications method' do

    context 'when a Setting record exists' do
      before { @setting = Setting.create! }
      it 'should return the value of the setting'  do
        Setting.first.update :enable_notifications => true
        Setting.enable_notifications.should == true
      end
    end

    context 'when no Setting record exists' do
      it 'should create a Setting record' do
        expect { Setting.enable_notifications }.to change { Setting.count }.by(1)
      end

      it 'should return the value of the setting' do
        Setting.enable_notifications.should == Setting.properties[:enable_notifications].default
      end
    end
  end

  describe '.free_days_access_key method' do

    context 'when a Setting record exists' do
      before { @setting = Setting.create! }

      it 'should return the value of the setting' do
        Setting.first.update :free_days_access_key => 'thekey'
        Setting.free_days_access_key.should == 'thekey'
      end
    end

    context 'when no Setting record exists' do
      before { Setting.stub!(:generate_free_days_access_key => 'generated_key') }

      it 'should create a Setting record' do
        expect { Setting.free_days_access_key }.to change { Setting.count }.by(1)
      end

      it 'should return the value of the setting' do
        Setting.free_days_access_key.should == 'generated_key'
      end
    end
  end

  describe '#generate_free_days_access_key method' do
    before do
      Setting.stub! :generate_free_days_access_key => 'generated_key'
      @setting = Setting.create! :free_days_access_key => 'one'
    end

    it 'should generate new value of :free_days_access_key' do
      @setting.generate_free_days_access_key
      @setting.free_days_access_key.should == 'generated_key'
    end
  end

end

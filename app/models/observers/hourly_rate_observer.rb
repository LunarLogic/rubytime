class HourlyRateObserver
  include DataMapper::Observer

  observe HourlyRate

  ['create','update','destroy'].each do |operation_type|
    after operation_type do
      HourlyRateLog.create :operation_type => operation_type, :operation_author => self.operation_author, :hourly_rate => self
    end
  end
  
end

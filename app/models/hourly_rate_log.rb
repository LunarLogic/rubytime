class HourlyRateLog
  include DataMapper::Resource
  
  VALID_OPERATION_TYPES = ['create', 'update', 'destroy']
  ATTRIBUTES_TO_LOG = [:project_id, :role_id, :takes_effect_at, :value, :currency_id]
  
  property :id, Serial
  property :logged_at, DateTime
  property :operation_type, String, :nullable => false
  property :operation_author_id, Integer, :nullable => false
  property :hr_id,                      Integer, :writer => :private
  property :hr_project_id,              Integer, :writer => :private
  property :hr_role_id,                 Integer, :writer => :private
  property :hr_takes_effect_at,         Date,    :writer => :private
  property :hr_value,                   BigDecimal, :writer => :private, :scale => 2, :precision => 10
  property :hr_currency_id,             Integer, :writer => :private
  
  belongs_to :operation_author, :model => User, :child_key => [:operation_author_id]
  belongs_to :hr_currency, :model => Currency, :child_key => [:hr_currency_id]
  
  default_scope(:default).update(:order => [:logged_at])
  
  validates_within :operation_type, :set => VALID_OPERATION_TYPES
  validates_present :hr_id, :message => 'No hourly rate assigned'
  
  def hourly_rate=(hourly_rate)    
    (ATTRIBUTES_TO_LOG + [:id]).each do |attr_to_log|
      self.send("hr_#{attr_to_log}=", hourly_rate ? hourly_rate.send(attr_to_log) : nil)
    end
  end
  
  before :save do
    self.logged_at = DateTime.now unless logged_at
    
    if operation_type == 'destroy'
      ATTRIBUTES_TO_LOG.each do |attr_not_to_log|
        self.send("hr_#{attr_not_to_log}=", nil)
      end
    end
  end

end

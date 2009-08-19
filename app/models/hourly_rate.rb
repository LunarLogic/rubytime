class HourlyRate
  include DataMapper::Resource
  
  VALID_CURRENCIES = ['dollar', 'zloty', 'euro', 'pound']
  
  property :project_id, Integer, :nullable => false, :key => true
  property :role_id, Integer, :nullable => false, :key => true
  property :takes_effect_at, Date, :nullable => false, :key => true
  property :value_multiplied_by_100, Integer, :accessor => :private
  property :currency, String, :nullable => false

  belongs_to :project
  belongs_to :role
  
  validates_is_unique :takes_effect_at, :scope => [:project_id, :role_id], :message => 'There already exists hourly rate for that project, role and date.'
  validates_present :value
  validates_within :currency, :set => VALID_CURRENCIES
  
  default_scope(:default).update(:order => [:takes_effect_at])
  
  def value=(value)
    attribute_set(:value_multiplied_by_100, value ? value * 100.0 : nil)
  end
  
  def value
    attribute_get(:value_multiplied_by_100) ? attribute_get(:value_multiplied_by_100) / 100.0 : nil
  end

end

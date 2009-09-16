class HourlyRate
  include DataMapper::Resource
    
  property :id, Serial
  property :project_id, Integer, :nullable => false
  property :role_id, Integer, :nullable => false
  property :takes_effect_at, Date, :nullable => false
  property :value, BigDecimal, :scale => 2, :precision => 10, :nullable => false
  property :currency_id, Integer, :nullable => false

  belongs_to :project
  belongs_to :role
  belongs_to :currency
  
  validates_is_unique :takes_effect_at, :scope => [:project_id, :role_id], :message => 'There already exists hourly rate for that project, role and date.'
  validates_present :operation_author
  
  default_scope(:default).update(:order => [:takes_effect_at])
  
  attr_accessor :operation_author
  attr_accessor :date_format_for_json
  
  def value=(value)
    attribute_set(:value, value.blank? ? nil : value)
  end

  def value_formatted
    value.to_s('F')
  end
  
  def succ
    HourlyRate.first(:takes_effect_at.gt => takes_effect_at, :project_id => project.id, :role_id => role.id, :order => [:takes_effect_at.asc])
  end
  
  def activities
    conditions = {
      :project_id => project_id,
      'user.role_id' => role_id,
      :date.gte => takes_effect_at
    }
    conditions[:date.lte] = succ.takes_effect_at - 1 if succ
    
    Activity.all(conditions.merge :order => [:date.asc, :project_id.asc, :id.asc])
  end

  def self.find_for(params)
    # TODO optimize this method, so it does not query DB each time activity.price is called (see any report showing prices )
    return nil if params[:role_id].nil? || params[:project_id].nil? || params[:date].nil?
    first(
      :conditions => ["takes_effect_at <= ? AND project_id = ? AND role_id = ? ", params[:date], params[:project_id], params[:role_id] ],
      :order => [:takes_effect_at.desc]
    )
  end
  
  def self.find_for_activity(activity)
    return nil if activity.user.nil?
    find_for( 
      :role_id => activity.user.role.id,
      :project_id => activity.project_id,
      :date => activity.date
    )
  end

  def to_json
    { :id => id,
      :project_id => project_id,
      :role_id => role_id,
      :takes_effect_at => (date_format_for_json ? takes_effect_at.formatted(date_format_for_json) : takes_effect_at),
      :takes_effect_at_unformatted => takes_effect_at,
      :value => value_formatted,
      :currency => currency,
      :error_messages => error_messages
    }.to_json
  end
  
  def to_money
    Money.new(value, currency)
  end
  
  def error_messages
    errors.full_messages.join('. ')
  end
  
  def *(numeric)
    to_money * numeric
  end
    
  before :destroy do
    if activities.count > 0
      errors.add(:base, 'Cannot destroy: There are activities that use this hourly rate.')
      throw :halt
    end
  end

end

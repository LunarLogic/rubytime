class HourlyRate
  include DataMapper::Resource
  
  VALID_CURRENCIES = ['dollar', 'zloty', 'euro', 'pound']
  
  property :id, Serial
  property :project_id, Integer, :nullable => false
  property :role_id, Integer, :nullable => false
  property :takes_effect_at, Date, :nullable => false
  property :value, BigDecimal, :scale => 2, :precision => 10, :nullable => false
  property :currency, String, :nullable => false

  belongs_to :project
  belongs_to :role
  
  validates_is_unique :takes_effect_at, :scope => [:project_id, :role_id], :message => 'There already exists hourly rate for that project, role and date.'
  validates_present :operation_author
  validates_within :currency, :set => VALID_CURRENCIES
  
  default_scope(:default).update(:order => [:takes_effect_at])
  
  attr_accessor :operation_author
  attr_accessor :date_format_for_json
  
  def value=(value)
    attribute_set(:value, value.blank? ? nil : value)
  end

  def value_formatted
    value.to_s('F')
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
  
  def error_messages
    errors.full_messages.join('. ')
  end

end

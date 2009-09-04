class HourlyRate
  include DataMapper::Resource
  
  VALID_CURRENCIES = ['dollar', 'zloty', 'euro', 'pound']
  
  property :id, Serial
  property :project_id, Integer, :nullable => false
  property :role_id, Integer, :nullable => false
  property :takes_effect_at, Date, :nullable => false
  property :value_multiplied_by_100, Integer, :accessor => :private
  property :currency, String, :nullable => false

  belongs_to :project
  belongs_to :role
  
  validates_is_unique :takes_effect_at, :scope => [:project_id, :role_id], :message => 'There already exists hourly rate for that project, role and date.'
  validates_present :value, :operation_author
  validates_within :currency, :set => VALID_CURRENCIES
  
  default_scope(:default).update(:order => [:takes_effect_at])
  
  attr_accessor :operation_author
  attr_accessor :date_format_for_json
  
  def value=(value)
    attribute_set(:value_multiplied_by_100, (not value.nil? and not value.blank?) ? value.to_f * 100.0 : nil)
  end
  
  def value
    attribute_get(:value_multiplied_by_100) ? attribute_get(:value_multiplied_by_100) / 100.0 : nil
  end


  def self.find_for(params)
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
      :value => value,
      :currency => currency,
      :error_messages => error_messages
    }.to_json
  end
  
  def error_messages
    errors.full_messages.join('. ')
  end

end

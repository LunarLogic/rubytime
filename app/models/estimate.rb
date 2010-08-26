class Estimate

  MAX_MINUTES = 999999
  include DataMapper::Resource

  property :project_id,       Integer, :key => true
  property :activity_type_id, Integer, :key => true
  property :minutes, Integer
  property :minutes_to_go, Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime

  belongs_to :project
  belongs_to :activity_type

  validates_is_unique :activity_type_id, :scope => :project_id
  validates_present :minutes, :unless => proc { |estimate| estimate.minutes_to_go.nil? }, :message => 'Minutes must not be blank when minutes to go is set.'
  validates_is_number :minutes, :minutes_to_go, :gte => 0, :lte => MAX_MINUTES, :integer_only => true, :allow_nil => true
  validates_with_method :minutes_to_go, :method => :validates_minutes_to_go

  def minutes=(minutes)
    self[:minutes] = minutes.blank? ? nil : minutes
  end

  def minutes_to_go=(minutes_to_go)
    self[:minutes_to_go] = minutes_to_go.blank? ? nil : minutes_to_go
  end

  def save_or_destroy
    if minutes.nil? and minutes_to_go.nil?
      new? ? true : destroy
    else
      save
    end
  end

  def validates_minutes_to_go
    if minutes and minutes_to_go and minutes_to_go.to_i > minutes.to_i
      [false, "Minutes to go must not be greater than minutes."]
    else
      true
    end
  end

end

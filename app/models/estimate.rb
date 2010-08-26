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
  validates_is_number :minutes, :minutes_to_go, :gte => 0, :lte => MAX_MINUTES, :allow_nil => true
  validates_with_method :minutes, :method => :validates_minutes_must_be_integer
  validates_with_method :minutes_to_go, :method => :validates_minutes_to_go_must_be_integer

  def minutes=(minutes)
    self[:minutes] = minutes.blank? ? nil : minutes
    @original_minutes = minutes
  end

  def minutes_to_go=(minutes_to_go)
    self[:minutes_to_go] = minutes_to_go.blank? ? nil : minutes_to_go
    @original_minutes_to_go = minutes_to_go
  end

  # NOTE: @original_minutes and @original_minutes_to_go were introduced to allow "must be integer" validations
  # without the fix, values assigned to :minutes and :minutes_to_go were converted to integer before validation
  # The getters :original_minutes and :original_minutes_to_go are used to display data entered by user to form inputs

  def original_minutes
    @original_minutes or minutes
  end

  def original_minutes_to_go
    @original_minutes_to_go or minutes_to_go
  end

  def save_or_destroy
    if minutes.nil? and minutes_to_go.nil?
      new? ? true : destroy
    else
      save
    end
  end

  def validates_minutes_must_be_integer
    if @original_minutes and not @original_minutes.to_i == @original_minutes.to_f
      [false, "Minutes must be integer number"]
    else
      true
    end
  end

  def validates_minutes_to_go_must_be_integer
    if @original_minutes_to_go and not @original_minutes_to_go.to_i == @original_minutes_to_go.to_f
      [false, "Minutes to go must be integer number"]
    else
      true
    end
  end

end

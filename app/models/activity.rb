class Activity
  HOURS_REGEX = /^\d{1,2}([\.,]\d{1}|:[0-5]\d)?$/

  include DataMapper::Resource
  
  property :id,          Serial
  property :comments,    Text, :nullable => false
  property :date,        Date, :nullable => false, :index => true
  property :minutes,     Integer, :nullable => false, :auto_validation => false
  property :project_id,  Integer, :nullable => false, :index => true
  property :activity_type_id, Integer, :index => true
  property :user_id,     Integer, :nullable => false, :index => true
  property :invoice_id,  Integer, :index => true
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  validates_format :hours, :with => HOURS_REGEX, :if => proc { |a| a.minutes.nil? }
  validates_with_method :hours, :method => :check_max_hours

  belongs_to :project
  belongs_to :activity_type
  belongs_to :user
  belongs_to :invoice
  
  def available_main_activity_types
    ActivityType.available(project, nil, self)
  end
  
  def available_sub_activity_types
    return [] if main_activity_type.nil?
    ActivityType.available(project, main_activity_type, self)
  end
  
  def main_activity_type_id
    return nil unless activity_type
    activity_type.parent ? activity_type.parent.id : activity_type.id
  end
  
  def main_activity_type
    ActivityType.get(main_activity_type_id)
  end
  
  def main_activity_type_id=(main_activity_type_id)
    main_activity_type = ActivityType.get(main_activity_type_id)
    self.activity_type = main_activity_type unless sub_activity_type_id and ActivityType.get(sub_activity_type_id).parent == main_activity_type
  end
  
  def main_activity_type=(main_activity_type)
    self.main_activity_type_id = main_activity_type.id
  end
  
  def sub_activity_type_id
    return nil unless activity_type
    activity_type.parent ? activity_type.id : nil
  end
  
  def sub_activity_type
    ActivityType.get(sub_activity_type_id)
  end
  
  def sub_activity_type_id=(sub_activity_type_id)
    self.activity_type = ActivityType.get(sub_activity_type_id) unless sub_activity_type_id.nil?
  end
  
  def sub_activity_type=(sub_activity_type)
    self.sub_activity_type_id = sub_activity_type.id
  end

  # Returns n recent activities
  def self.recent(n_)
    all(:order => [:date.desc], :limit => n_)
  end
  
  def self.not_invoiced
    all(:invoice_id => nil)
  end
      
  # Needed only for User#activities in calendar view
  def self.for(time)
    year, month = case time
    when :this_month
      [Date.today.year, Date.today.month]
    when Hash
      [time[:year], time[:month]]
    end

    raise ArgumentError.new("You have to pass either :now or a Hash with :year and :month") if year.nil? || month.nil?
    if !(1..12).include?(month) || year > Date.today.year
      raise ArgumentError.new("Month should be in range 1-12 and year not greater than #{Date.today.year}") 
    end
    
    all :order => [:date.desc], :date.gte => Date.civil(year, month, 1), :date.lte => Date.civil(year, month, -1)
  end

  # Sets hours and minutes properties
  #
  # It automatically converts hours to minutes allowing to 
  # specify hours as strings in following formats:
  # "7" "7,5" "7.5" "7:30"
  def hours=(hours)
    time = hours.to_s.strip
    @hours = time
    if time =~ HOURS_REGEX
      if time.index(':')
        h, m = time.split(/:/)
        self.minutes = h.to_i * 60 + m.to_i
      else
        self.minutes = time.gsub(/,/, '.').to_f * 60
      end
    else
      self.minutes = nil
    end
  end
  
  def hours
    @hours ||= (minutes && format("%d:%.2d", minutes / 60, minutes % 60))
  end
  
  def invoiced?
    !!self.invoice_id
  end
  
  # Checks if activity is locked.
  #
  # It is considered to be locked when it's invoiced
  # and that invoice has been already issued.
  def locked?
    self.invoiced? && self.invoice.issued?
  end
  
  def deletable_by?(user)
    self.user == user || user.is_admin?
  end

  def self.is_activity_day(user, thisday)
    user.activities.count(:date => thisday) > 0
  end
  
  def full_type_name
    return nil if activity_type.nil?
    activity_type.parent ? "#{activity_type.parent.name} -> #{activity_type.name}" : "#{activity_type.name}"
  end
  
  protected
  
  # Checks if hours for this activity are under 24 hours
  def check_max_hours
    if minutes
      if minutes > (24 * 60)
        self.minutes = nil
        return [false, "Hours must be under 24"]
      end
    end
    true
  end
end

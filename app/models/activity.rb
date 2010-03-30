class Activity
  HOURS_REGEX = /^\d{1,2}([\.,]\d{1}|:[0-5]\d)?$/

  include DataMapper::Resource
  
  property :id,          Serial
  property :comments,    Text
  property :date,        Date, :nullable => false, :index => true
  property :minutes,     Integer, :nullable => false, :auto_validation => false
  property :project_id,  Integer, :nullable => false, :index => true
  property :activity_type_id, Integer, :index => true
  property :user_id,     Integer, :nullable => false, :index => true
  property :invoice_id,  Integer, :index => true
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  validates_present :comments, :if => proc { |a| a.activity_type.nil? }
  validates_format :hours, :with => HOURS_REGEX, :if => proc { |a| a.minutes.nil? }
  validates_with_method :hours, :method => :check_max_hours
  validates_absent  :activity_type_id, :unless => proc { |a| a.activity_type_required? }
  validates_present :activity_type_id,     :if => proc { |a| a.activity_type_required? }
  validates_with_method :activity_type_id, :method => :activity_type_must_be_assigned_to_project, :if => proc { |a| a.activity_type_required? and a.activity_type }
  validates_with_method :activity_custom_property_values, :method => :required_custom_properties_are_present
  validates_with_method :activity_custom_property_values, :method => :custom_properties_are_valid

  belongs_to :project
  belongs_to :activity_type
  belongs_to :user
  belongs_to :invoice
  
  has n, :activity_custom_property_values
  
  def available_main_activity_types
    return [] if project.nil?
    project.activity_types.all(:parent_id => nil)
  end
  
  def available_sub_activity_types
    return [] if main_activity_type.nil? or project.nil?
    project.activity_types.all(:parent_id => main_activity_type.id)
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
  
  def breadcrumb_name
    return nil if activity_type.nil?
    activity_type.breadcrumb_name
  end
  
  def activity_type_required?
    project and project.activity_types.count > 0
  end
  
  def custom_properties=(custom_properties)
    @custom_properties = {}
    custom_properties.each_pair do |custom_property_id, value|
      @custom_properties[custom_property_id.to_i] = ActivityCustomPropertyValue.new(:value => value).value unless value.blank?
    end
    @custom_properties
  end
  
  def custom_properties
    @custom_properties ||= activity_custom_property_values.inject({}) do |agg, property| 
      agg[property.activity_custom_property.id] = property.value
      agg
    end
  end
  
  after :save do
    activity_custom_property_values.all(:activity_custom_property_id.not => custom_properties.keys).each { |pv| pv.destroy }
    
    records_from_custom_properties.each { |activity_custom_property_value| activity_custom_property_value.save }
  end
  
  before :destroy do
    activity_custom_property_values.each { |pv| pv.destroy }
  end
  
  def self.custom_property_values_sum(activities, custom_property)
    activities.inject(0) { |sum, activity| sum + (activity.custom_properties[custom_property.id] || 0) }
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
  
  def activity_type_must_be_assigned_to_project
    project.activity_types.get(activity_type_id) ? true : [false, "Activity type must be one of those assigned to the project"]
  end
  
  def required_custom_properties_are_present
    required_custom_properties = ActivityCustomProperty.all(:required => true)
    if required_custom_properties.map { |acp| acp.id }.none? { |id| custom_properties[id].blank? }
      true
    else
      [false, "The following custom properties are required: " + required_custom_properties.map { |acp| acp.name }.join(', ')]
    end
  end
  
  def records_from_custom_properties
    records = []
    custom_properties.each_pair do |custom_property_id, custom_property_value|
      activity_custom_property = ActivityCustomProperty.get(custom_property_id)
      
      activity_custom_property_value = 
        # TODO: the problematic sentence shown below produces wrong SQL while updating the activity custom property values from controller.
        # It receives activity_custom_property_values of all of user's activites instead of 'self' one. Why is that?
        #
        # The problematic code:
        # activity_custom_property_values.first(:activity_custom_property_id => activity_custom_property.id) ||
        #
        # The code that works:
        # ActivityCustomPropertyValue.first(:activity_custom_property_id => activity_custom_property.id, :activity_id => self.id) ||
        #
        # Thank you for your attention ;-)
        ActivityCustomPropertyValue.first(:activity_custom_property_id => activity_custom_property.id, :activity_id => self.id) ||
        ActivityCustomPropertyValue.new(:activity_custom_property => activity_custom_property, :activity => self)
      
      activity_custom_property_value.value = custom_property_value
      records << activity_custom_property_value
    end
    records
  end
  
  def custom_properties_are_valid
    invalid_custom_property_values = records_from_custom_properties.select { |value| value.incorrect_value? }
    if invalid_custom_property_values.empty?
      true
    else
      [false, "The following custom properties are invalid: " + invalid_custom_property_values.map { |v| v.activity_custom_property.name }.join(', ')]
    end
  end
  
end

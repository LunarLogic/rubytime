class Activity
  # TODO: move to a custom DM type
  HOURS_REGEX = /^(\d{1,2}([\.,]\d{1,2}h?|:[0-5]\d|[hm])?|[\.,]\d{1,2}h?)$/

  include DataMapper::Resource
  
  property :id,          Serial
  property :comments,    Text
  property :date,        Date, :required => true, :index => true
  property :minutes,     Integer, :required => true, :auto_validation => false
  property :project_id,  Integer, :required => true, :index => true
  property :role_id,     Integer, :required => true, :index => true, :default => -1
  property :activity_type_id, Integer, :index => true
  property :user_id,     Integer, :required => true, :index => true
  property :invoice_id,  Integer, :index => true
  property :price_value, Decimal, :scale => 2, :precision => 10
  property :price_currency_id, Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  validates_presence_of :comments, :if => proc { |a| a.activity_type.nil? }
  validates_with_method :hours, :method => :validate_hours
  validates_absence_of  :activity_type_id, :unless => proc { |a| a.activity_type_required? }
  validates_presence_of :activity_type_id,     :if => proc { |a| a.activity_type_required? }
  validates_with_method :activity_type_id, :method => :activity_type_must_be_assigned_to_project, :if => proc { |a| a.activity_type_required? and a.activity_type }
  validates_with_method :activity_custom_property_values, :method => :required_custom_properties_are_present
  validates_with_method :activity_custom_property_values, :method => :custom_properties_are_valid
  validates_presence_of :hourly_rate, :message => 'There is no hourly rate for that day. Please contact the person responsible for hourly rates management.'

  belongs_to :project
  belongs_to :role
  belongs_to :activity_type
  belongs_to :user, :child_key => [:user_id]
  belongs_to :invoice
  belongs_to :price_currency, :model => Currency, :child_key => [:price_currency_id]

  before :valid? do
    if (new? || attribute_dirty?(:user_id) || attribute_dirty?(:date))
      self.role = role_for_date
    end
  end

  # Returns the right user version for activity date
  def role_for_date
    user && date && user.version(self.date).role
  end
  
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
    self.main_activity_type_id = main_activity_type && main_activity_type.id
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
    self.sub_activity_type_id = sub_activity_type && sub_activity_type.id
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

    if year.nil? || month.nil?
      raise ArgumentError.new("You have to pass either :now or a Hash with :year and :month")
    end

    if !(1..12).include?(month) || year > Date.today.year
      raise ArgumentError.new("Month should be in range 1-12 and year not greater than #{Date.today.year}") 
    end
    
    all :date => Date.civil(year, month, 1)..Date.civil(year, month, -1), :order => [:date.desc]
  end

  def minutes=(minutes)
    @hourly_rate_memoized = nil
    attribute_set(:minutes, minutes)
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
      elsif time.index('h')
        self.minutes = (time.gsub(/,/, '.').to_f * 60).to_i
      elsif time.index('m')
        self.minutes = time.to_i
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
  
  def duration
    minutes ? Duration.new(minutes * 1.minute) : nil
  end
  
  def duration=(duration)
    self.minutes = duration ? (1.0 * duration / 1.minute) : nil
  end

  def hourly_rate
    @hourly_rate_memoized ||= HourlyRate.find_for_activity(self)
  end
  
  def price
    if price_value and price_currency
      Money.new(price_value, price_currency)
    else
      money = hourly_rate && hourly_rate * (minutes / 60.0)
      money.value = money.value.round_to_2_digits unless money.nil?
      money
    end
  end
  
  def price=(money)
    self.price_value = money ? money.value.round_to_2_digits : nil
    self.price_currency = money ? money.currency : nil
  end
  
  def role_name
    self.role.name
  end

  def price_as_json
    price.as_json if price
  end

  def price_frozen?
    persistent = Activity.get(id)
    not persistent.nil? and
      not persistent.price_value.nil? and
      not persistent.price_currency.nil?
  end

  def freeze_price!
    raise Exception.new('Price is already frozen') if price_frozen?
    success = if price
      update(:price_value => price.value, :price_currency => price.currency)
    else
      update(:price_value => nil,         :price_currency => nil)
    end
    success or raise Exception.new("Can't freeze price")
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

  def notify_project_managers(kind_of_change)
    Employee.managers.each do |project_manager|
      UserMailer.timesheet_changes_notifier(
        :activity => self,
        :kind_of_change => kind_of_change,
        :project_manager => project_manager,
        :to => project_manager.email,
        :from => Rubytime::CONFIG[:mail_from],
        :subject => "Timesheet update notification"
      ).deliver
    end
  end

  def notify_project_managers_if_enabled(kind_of_change)
    notify_project_managers(kind_of_change) if Setting.enable_notifications
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
    # Just to let DM know the object is not clean
    self.updated_at = DateTime.now
    @custom_properties_modified = true
    @custom_properties
  end
  
  def custom_properties
    @custom_properties ||= activity_custom_property_values.inject({}) do |agg, property| 
      agg[property.activity_custom_property_id] = property.value
      agg
    end
  end
  
  after :save do
    if @custom_properties_modified
      @custom_properties_modified = false
      unassigned = activity_custom_property_values.all(:activity_custom_property_id.not => custom_properties.keys)
      unassigned.each(&:destroy)
      records_from_custom_properties.each(&:save)
    end
  end
  
  before :destroy do
    activity_custom_property_values.each { |pv| pv.destroy }
  end
  
  def self.custom_property_values_sum(activities, custom_property)
    activities.inject(0) { |sum, activity| sum + (activity.custom_properties[custom_property.id] || 0) }
  end
  
  private
  
  # Checks if hours for this activity are under 24 hours
  def validate_hours
    if minutes
      if minutes > (24 * 60)
        self.minutes = nil
        return [false, "Hours must be under 24"]
      end
    end

    if (HOURS_REGEX =~ hours).nil?
      return [false, "Hours has an invalid format"]
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
        activity_custom_property_values.first(:activity_custom_property_id => activity_custom_property.id) ||
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

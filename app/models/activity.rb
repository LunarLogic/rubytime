class Activity
  # TODO: move to a custom DM type
  HOURS_REGEX = /^\d{1,2}([\.,]\d{1}|:[0-5]\d)?$/

  include DataMapper::Resource
  
  property :id,          Serial
  property :comments,    Text, :required => true
  property :date,        Date, :required => true, :index => true
  property :minutes,     Integer, :required => true, :auto_validation => false
  property :project_id,  Integer, :required => true, :index => true
  property :user_id,     Integer, :required => true, :index => true
  property :invoice_id,  Integer, :index => true
  property :price_value, BigDecimal, :scale => 2, :precision => 10
  property :price_currency_id, Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  validates_with_method :hours, :method => :validate_hours
  validates_present :hourly_rate, :message => 'There is no hourly rate for that day. Please contact the person responsible for hourly rates management.'

  belongs_to :project
  belongs_to :user, :child_key => [:user_id]
  belongs_to :invoice
  belongs_to :price_currency, :model => Currency, :child_key => [:price_currency_id]
  
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

  def notify_project_managers_about_saving(kind_of_change)
    Employee.managers.each do |project_manager|
      m = UserMailer.new(:activity => self, :kind_of_change => kind_of_change, :project_manager => project_manager)
      m.dispatch_and_deliver(:timesheet_changes_notifier,
        :to => project_manager.email,
        :from => Rubytime::CONFIG[:mail_from],
        :subject => "Timesheet update notification")
    end
  end

  # FIXME: wtf, double underscores?
  def notify_project_managers_about_saving__if_enabled(kind_of_change)
    notify_project_managers_about_saving(kind_of_change) if Setting.enable_notifications
  end
  
  protected
  
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
end

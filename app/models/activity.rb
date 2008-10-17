class Activity
  HOURS_REGEX = /^\d+([\.,]\d+|:[0-5]\d)?$/

  include DataMapper::Resource
  
  property :id,          Serial
  property :comments,    Text, :nullable => false
  property :date,        Date, :nullable => false
  property :minutes,     Integer, :nullable => false, :auto_validation => false
  property :project_id,  Integer, :nullable => false
  property :user_id,     Integer, :nullable => false
  property :invoice_id,  Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  attr_reader :hours
  
  validates_format :hours, :with => HOURS_REGEX, :if => proc { |a| a.minutes.nil? }
  validates_with_method :hours, :method => :check_max_hours

  belongs_to :project
  belongs_to :user
  belongs_to :invoice
  
  # Returns n recent activities
  def self.recent(n_)
    all(:order => [:date.desc], :limit => n_)
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
  
  # Checks if activity is locked.
  #
  # It is considered to be locked when it belongs to
  # an invoice and that invoice has been already issued.
  def locked?
    !!(self.invoice && self.invoice.issued?)
  end
  
  protected
  
  # Checks if hours for this activity are under 24 hours
  def check_max_hours
    return true unless minutes
    minutes / 60 <= 24 ? true : [false, "Hours must be under 24"]
  end
end

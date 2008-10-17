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
    value = hours.to_s.strip
    @hours = value
    if value =~ HOURS_REGEX
      if value =~ /^\d+$/
        self.minutes = value.to_i * 60
      elsif value =~ /^\d+[\.,]\d+$/
        self.minutes = value.sub(/,/, '.').to_f * 60
      elsif value =~ /^(\d+):(\d+)$/
        self.minutes = $1.to_i * 60 + $2.to_i
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
end

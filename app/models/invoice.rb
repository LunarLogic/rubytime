class Invoice
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String, :required => true, :unique => true, :index => true
  property :notes,       Text
  property :user_id,     Integer, :required => true, :index => true
  property :client_id,   Integer, :required => true, :index => true
  property :issued_at,   DateTime
  property :created_at,  DateTime
 
  belongs_to :client
  belongs_to :user
  has n, :activities

  attr_accessor :new_activities

  validates_with_method :activities, :method => :validate_activities

  after :save do
    unless new_activities.blank?
      new_activities.each { |activity| activity.update(:invoice_id => id) }
    end
  end
  
  before :destroy do
    throw :halt if issued?
    activities.update!(:invoice_id => nil)
  end

  def validate_activities
    if new_activities.blank? || new_activities.all?(&:valid?)
      true
    else
      [false, "Some of activities are invalid (#{new_activities.first.errors.first.first})."]
    end
  end

  def self.pending
    all(:issued_at => nil)
  end
  
  def self.issued
    all(:issued_at.not => nil)
  end

  def issue!
#    transaction do
      activities.each { |a| a.freeze_price! }
      update(:issued_at => DateTime.now)
#    end
  end
  
  def issued?
    !self.issued_at.nil?
  end

  def activity_id=(ids)
    self.new_activities = Activity.all(:id => ids, :invoice_id => nil)
  end
end

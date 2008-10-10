class Activity
  include DataMapper::Resource

  property :id,          Serial
  property :comments,    Text, :nullable => false
  property :date,        Date, :nullable => false
  property :minutes,     Integer, :nullable => false
  property :project_id,  Integer, :nullable => false
  property :user_id,     Integer, :nullable => false
  property :invoice_id,  Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  validates_within :minutes, :set => 1..1000, :message => "is out of range"

  belongs_to :project
  belongs_to :user
  belongs_to :invoice
  
  def self.recent(limit)
    all(:order => [:created_at.desc], :limit => limit)
  end
  
  def locked?
    !!(self.invoice && self.invoice.issued?)
  end
end

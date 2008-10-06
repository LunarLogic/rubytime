class Activity
  include DataMapper::Resource

  property :id,            Serial
  property :comments,      Text
  property :date,          Date, :nullable => false
  property :minutes,       Integer, :nullable => false
  property :project_id,    Integer, :nullable => false
  property :user_id,       Integer, :nullable => false
  property :invoice_id,    Integer
  property :updated_at,    DateTime
  property :created_at,    DateTime
  
  belongs_to :project
  belongs_to :user
  belongs_to :invoice
  
  def locked?
    !!(self.invoice && self.invoice.locked?)
  end
end

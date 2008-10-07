class Invoice
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String, :nullable => false, :unique => true
  property :notes,       Text
  property :user_id,     Integer, :nullable => false
  # property :user_id,   Integer, :nullable => false # what is this user for?
  property :issued_at,   DateTime, :default => nil
  property :created_at,  DateTime
 
  belongs_to :client, :child_key => [:user_id]
  # belongs_to :user # what is this user for?
  
  def issued?
    !self.issued_at.nil?
  end
end

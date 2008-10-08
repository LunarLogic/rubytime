class Invoice
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String, :nullable => false, :unique => true
  property :notes,       Text
  property :user_id,     Integer, :nullable => false
  property :client_id,   Integer, :nullable => false
  property :issued_at,   DateTime, :default => nil
  property :created_at,  DateTime
 
  belongs_to :client
  belongs_to :user
  
  def issued?
    !self.issued_at.nil?
  end
end

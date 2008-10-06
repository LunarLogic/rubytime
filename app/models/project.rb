class Project
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true
  property :description,  Text
  property :client_id,    Integer, :nullable => false
  property :active,       Boolean, :nullable => false, :default => true
  property :created_at,   DateTime
  
  belongs_to :client
end

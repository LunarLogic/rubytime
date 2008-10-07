class Project
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true
  property :description,  Text
  property :user_id,    Integer, :nullable => false
  property :active,       Boolean, :nullable => false, :default => true
  property :created_at,   DateTime
  
  belongs_to :client, :child_key => [:user_id]
  has n, :activities
  has n, :users, :through => :activities
end

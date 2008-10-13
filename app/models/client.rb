class Client
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false
  property :description,  Text
  property :email,        String
  property :active,       Boolean, :nullable => false, :default => true
  
  has n, :projects
  has n, :invoices
  has n, :client_users
  
  def self.active
    all(:active => true)
  end
end

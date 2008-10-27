class Client
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false
  property :description,  Text
  property :email,        String
  property :active,       Boolean, :nullable => false, :default => true
  
  has n, :projects
  has n, :activities, :through => :projects
  has n, :invoices
  has n, :client_users
  
  before :destroy do
    throw :halt if invoices.count > 0 
  end
  
  before :destroy, :destroy_client_users
  
  def self.active
    all(:active => true)
  end
  
  protected 
  
  def destroy_client_users
    client_users.destroy!
  end
end

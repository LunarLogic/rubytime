class Client
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :index => true
  property :description,  Text
  property :email,        String
  property :active,       Boolean, :nullable => false, :default => true
  
  has n, :projects
  has n, :activities, :through => :projects
  has n, :invoices
  has n, :client_users
  
  before :destroy do
    throw :halt if invoices.count > 0
    throw :halt if activities.count > 0
  end
  
  before :destroy, :destroy_client_users_and_projects
  
  def self.active
    all(:active => true)
  end
  
  protected 
  
  def destroy_client_users_and_projects
    client_users.destroy!
    projects.destroy!
  end
end

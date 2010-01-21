class Client
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :required => true, :index => true
  property :description,  Text
  property :email,        String
  property :active,       Boolean, :required => true, :default => true
  
  has n, :projects
  has n, :activities, :through => :projects
  has n, :invoices
  has n, :client_users
  
  before :destroy do
    throw :halt if invoices.count > 0
    throw :halt if activities.count > 0
  end
  
  before :destroy, :destroy_client_users_and_projects
  
  default_scope(:default).update(:order => [:name])
  
  def self.active
    all(:active => true)
  end
  
  protected 
  
  def destroy_client_users_and_projects
    # TODO: 1. This code removes records without validation
    # TODO: 2. This code can leave garbage in the database (related records are not removed in a cascade)
    client_users.destroy!
    projects.each{|project| project.hourly_rates.destroy! }
    projects.destroy!
  end
end

class Project
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true, :index => true
  property :description,  Text, :lazy => false # workaround for bug #461 (http://wm.lighthouseapp.com/projects/4819/tickets/461-update_attributes-wrong-behaviour-with-lazy-attributes)
  property :client_id,    Integer, :nullable => false, :index => true
  property :active,       Boolean, :nullable => false, :default => true
  property :created_at,   DateTime
  
  belongs_to :client
  has n, :activities
  has n, :users, :through => :activities
  
  before :destroy do
    throw :halt if activities.count > 0
  end

  def self.active
    all(:active => true)
  end
end

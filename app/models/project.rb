class Project
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true, :index => true
  property :description,  Text
  property :client_id,    Integer, :nullable => false, :index => true
  property :active,       Boolean, :nullable => false, :default => true
  property :created_at,   DateTime
  
  belongs_to :client
  has n, :activities
  has n, :users, :through => :activities
  has n, :hourly_rates
  
  before :destroy do
    throw :halt if activities.count > 0
  end

  def self.active
    all(:active => true)
  end
  
  def calendar_viewable?(user)
    user.client == self.client || user.is_admin?
  end
  
  def hourly_rates_grouped_by_roles
    Role.all.inject({}) { |hash, role| hash[role] = []; hash }.update(hourly_rates.group_by { |hr| hr.role })
  end
end

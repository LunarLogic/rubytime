class Employee < User
  property :role_id, Integer
  
  belongs_to :role
  has n, :activities
  has n, :projects, :through => :activities
  
  validates_present :role
  
  before :destroy do
    throw :halt if activities.count > 0
  end
  
end

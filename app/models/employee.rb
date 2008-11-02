class Employee < User
  validates_present :role
  
  has n, :activities
  has n, :projects, :through => :activities
  
  before :destroy do
    throw :halt if activities.count > 0
  end
end

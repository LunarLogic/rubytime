class Employee < User
  property :role_id, Integer
  
  belongs_to :role
  has n, :activities
  has n, :projects, :through => :activities
  
  validates_present :role
end

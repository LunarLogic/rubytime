class Employee < User
  property :role_id, Integer
  
  belongs_to :role
  
  validates_present :role
end

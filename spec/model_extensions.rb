class User
  def another(same_sti_type = true)
    (same_sti_type ? self.class : User).first :id.not => self.id
  end
  
  def self.admin
    all :admin => true
  end
  
  def self.not_admin
    all :admin => false
  end
end
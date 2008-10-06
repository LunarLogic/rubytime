class User
  def self.not_admin
    all :type.not => "Admin"
  end
  
  def another
    User.first :id.not => self.id
  end
end
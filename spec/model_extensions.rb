class User
  def another(same_sti_type = true)
    (same_sti_type ? self.class : User).first :id.not => self.id
  end
end
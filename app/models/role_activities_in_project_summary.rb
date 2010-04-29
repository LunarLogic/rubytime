class RoleActivitiesInProjectSummary
  def initialize(role, activities)
    self.role = role
    self.non_billable_time = 0
    self.billable_time = 0
    self.price = Purse.new
    
    activities.each { |activity| self << activity }
  end
  
  attr_reader :role, :non_billable_time, :billable_time, :price
  
  def <<(activity)
    raise ArgumentError unless activity.role == role
    
    if activity.price
      self.billable_time += activity.duration
      self.price << activity.price
    else
      self.non_billable_time += activity.duration
    end
  end
  
  private 
  attr_writer :role, :non_billable_time, :billable_time, :price
end

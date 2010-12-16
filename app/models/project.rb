class Project
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :required => true, :unique => true, :index => true
  property :description,  Text
  property :client_id,    Integer, :required => true, :index => true
  property :active,       Boolean, :required => true, :default => true
  property :created_at,   DateTime

  attr_accessor :has_activities
  belongs_to :client
  has n, :project_activity_types
  has n, :activity_types, :through => :project_activity_types
  has n, :activities
  has n, :users, :through => :activities
  has n, :hourly_rates

  before :destroy do
    throw :halt if activities.count > 0
    
    hourly_rates.all.destroy!
  end

  # class methods

  def self.active
    all(:active => true)
  end

  def self.visible_for(user)
    if user.is_admin?
      all
    elsif user.is_employee?
      active
    else  # client
      user.client.projects
    end
  end

  def self.with_activities_for(user)
    all('activities.user_id' => user.id, :unique => true)
  end

  # instance methods

  def calendar_viewable?(user)
    user.client == self.client || user.is_admin?
  end

  def hourly_rates_grouped_by_roles
    Role.all.inject({}) { |hash, role| hash[role] = []; hash }.update(hourly_rates.group_by { |hr| hr.role })
  end

  def activity_type_ids
    activity_types.map { |at| at.id }
  end
  
  def activity_type_ids=(activity_type_ids)
    project_activity_types.all.destroy!
    (activity_type_ids + used_activity_type_ids).uniq.each do |activity_type_id|
      project_activity_types.create(:activity_type_id => activity_type_id)
    end
  end
  
  def used_activity_types
    ActivityType.all("activities.project_id" => id).map { |at| at.ancestors + [at] }.flatten
  end
  
  def used_activity_type_ids
    used_activity_types.map { |at| at.id }
  end

end

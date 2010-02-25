class Project
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String, :nullable => false, :unique => true, :index => true
  property :description,  Text
  property :client_id,    Integer, :nullable => false, :index => true
  property :active,       Boolean, :nullable => false, :default => true
  property :created_at,   DateTime

  attr_accessor :has_activities
  belongs_to :client
  has n, :activity_types, :through => Resource
  has n, :activities
  has n, :users, :through => :activities
  
  before :destroy do
    throw :halt if activities.count > 0
  end

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

  def calendar_viewable?(user)
    user.client == self.client || user.is_admin?
  end
  
  def activity_type_ids
    activity_types.map { |at| at.id }
  end
  
  def activity_type_ids=(activity_type_ids)
    activity_type_projects.all.destroy!
    (activity_type_ids + used_activity_type_ids).uniq.each { |activity_type_id| activity_type_projects.create(:activity_type_id => activity_type_id) }
  end
  
  def used_activity_types
    ActivityType.all("activities.project_id" => id).map { |at| at.ancestors + [at] }.flatten
  end
  
  def used_activity_type_ids
    used_activity_types.map { |at| at.id }
  end
  
end

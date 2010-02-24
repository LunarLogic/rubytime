class ActivityType
  include DataMapper::Resource
  
  property :id, Serial
  property :name,  String, :nullable => false, :index => true
  property :parent_id, Integer
  property :position, Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  is :tree, :order => :position
  is :list, :scope => [:parent_id]
  has n, :projects, :through => Resource
  has n, :activities
  
  before :destroy do
    children.each { |at| at.destroy }
  end
  
  def destroy_allowed?
    projects.empty? and children.all? { |at| at.destroy_allowed? }
  end
  
  def destroy(force = false)
    return false unless destroy_allowed? or force
    super()
  end
  
  def self.available(project, activity_type, activity = nil)
    return [] unless project
    
    parent_id = activity_type ? activity_type.id : nil
    extra_activity_type = activity ? activity.activity_type : nil
    
    ( project.activity_types(:parent_id => parent_id) +
      (extra_activity_type.nil? ? [] : ActivityType.all(:parent_id => parent_id, :id => (extra_activity_type.ancestors.to_a + [extra_activity_type]).map{|at| at.id}))
    ).uniq
  end

end

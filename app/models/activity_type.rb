class ActivityType
  include DataMapper::Resource
  
  property :id, Serial
  property :name,  String, :required => true, :index => true
  property :parent_id, Integer
  property :position, Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  is :tree, :order => :position
  is :list, :scope => [:parent_id]
  has n, :projects, :through => Resource
  has n, :activities
  
  validates_is_unique :name, :scope => :parent_id
  
  def breadcrumb_name
    parent ? "#{parent.breadcrumb_name} -> #{name}" : "#{name}"
  end
  
  before :destroy do
    children.each { |at| at.destroy }
  end
  
  def destroy_allowed?
    projects.empty? and activities.empty? and children.all? { |at| at.destroy_allowed? }
  end
  
  def destroy(force = false)
    return false unless destroy_allowed? or force
    super()
  end

end

class ActivityType
  include DataMapper::Resource
  
  property :id, Serial
  property :name,  String, :required => true, :index => true
  property :parent_id, Integer
  property :position, Integer
  property :active, Boolean, :required => true, :default => true
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  is :tree, :order => :position
  is :list, :scope => [:parent_id]
  has n, :project_activity_types
  has n, :projects, :through => :project_activity_types
  has n, :activities
  
  validates_is_unique :name, :scope => :parent_id

  before :destroy do
    children.each { |at| at.destroy }
  end

  def self.active
    all(:active => true)
  end

  def breadcrumb_name
    parent ? "#{parent.breadcrumb_name} -> #{name}" : "#{name}"
  end

  def parent_id=(id)
    self.attribute_set :parent_id, (id.blank?) ? nil : id
  end

  def destroy_allowed?
    projects.empty? and activities.empty? and children.all? { |at| at.destroy_allowed? }
  end
  
  def destroy(force = false)
    return false unless destroy_allowed? or force
    super()
  end

end

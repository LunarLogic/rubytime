class ProjectActivityType
  include DataMapper::Resource

  property :project_id,       Integer, :required => true, :key => true
  property :activity_type_id, Integer, :required => true, :key => true

  belongs_to :project
  belongs_to :activity_type
end

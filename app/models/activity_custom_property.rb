class ActivityCustomProperty
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false, :index => true
  property :unit, String, :nullable => true
  property :required, Boolean, :nullable => false, :default => false
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  validates_is_unique :name
  
  def destroy_allowed?
    true
  end

end

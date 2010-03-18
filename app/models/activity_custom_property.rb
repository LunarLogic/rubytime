class ActivityCustomProperty
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :nullable => false, :index => true
  property :unit, String, :nullable => true
  property :required, Boolean, :nullable => false, :default => false
  property :show_as_column_in_tables, Boolean, :nullable => false, :default => false
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  has n, :activity_custom_property_values
  
  validates_is_unique :name
  
  def destroy_allowed?
    activity_custom_property_values.count == 0
  end
  
  def destroy
    return false unless destroy_allowed?
    super()
  end

end

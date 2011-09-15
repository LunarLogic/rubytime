class ActivityCustomProperty
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true, :index => true
  property :unit, String, :required => false
  property :required, Boolean, :required => true, :default => false
  property :show_as_column_in_tables, Boolean, :required => true, :default => false
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  has n, :activity_custom_property_values
  
  validates_uniqueness_of :name
  
  def name_with_unit
    name + (unit.blank? ? "" : " (#{unit})")
  end
  
  def destroy_allowed?
    activity_custom_property_values.count == 0
  end
  
  def destroy
    return false unless destroy_allowed?
    super()
  end

end

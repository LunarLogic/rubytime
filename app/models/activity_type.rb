class ActivityType
  include DataMapper::Resource
  
  property :id, Serial
  property :name,  String, :nullable => false, :index => true
  property :parent_id, Integer
  property :updated_at,  DateTime
  property :created_at,  DateTime
  
  is :tree, :order => :name
  
  before :destroy do
    children.each { |at| at.destroy }
  end

end

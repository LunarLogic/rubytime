class Message
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :body, Text
  
  belongs_to :person
  belongs_to :recipient, :class_name => 'Person'
end

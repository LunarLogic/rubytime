# Rails HTML sanitization on some fields
class Entry
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :title, String
  property :body, Text
  property :extended, Text
  property :created_on, DateTime
  
  belongs_to :person
  has n, :comments
  xss_terminate :sanitize => [:body, :extended]
end

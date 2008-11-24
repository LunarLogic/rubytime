# in this model, the contents field needs to be sanitized with the whitelist, but the title field should be terminated (no tags)
class Page
  include DataMapper::Resource
  
  property :id, Integer, :serial => true
  property :contents, Text
  property :title, String
  
  xss_terminate :sanitize => [:contents]
  
end
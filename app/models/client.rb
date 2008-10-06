class Client < User
  property :description, Text
  
  has n, :projects
  has n, :invoices
end

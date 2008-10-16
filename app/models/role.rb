class Role
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :nullable => false, :unique => true
  
  has n, :employees
  
  def self.for_select
    all.map { |r| [r.id, r.name] }
  end
end

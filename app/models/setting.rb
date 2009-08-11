class Setting
  include DataMapper::Resource
  
  property :id, Serial
  property :enable_notifications, Boolean, :default  => true, :nullable => false
  
  def self.get
    first || create
  end
  
  def self.enable_notifications
    get.enable_notifications
  end

end

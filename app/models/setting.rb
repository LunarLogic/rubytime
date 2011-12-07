class Setting
  include DataMapper::Resource
  
  ACCESS_KEY_CHARS = "1234567890qwrtpsdfghjklzxcvbnmQWRTPSDFGHJKLZXCVBNM"
  
  property :id, Serial
  property :enable_notifications, Boolean, :default  => false, :required => true
  property :free_days_access_key, String,  :default => Proc.new { Setting.generate_free_days_access_key }, :required => true
  
  before :valid? do
    generate_free_days_access_key if free_days_access_key.blank?
  end
    
  def self.get
    first or create or raise DataMapper::ObjectNotFound
  end
  
  def self.enable_notifications
    get.enable_notifications
  end
  
  def generate_free_days_access_key
    self.free_days_access_key = Setting.generate_free_days_access_key
  end
  
  def self.free_days_access_key
    get.free_days_access_key
  end
  
  private

  def self.generate_free_days_access_key
    ACCESS_KEY_CHARS.generate_random(50)
  end

end

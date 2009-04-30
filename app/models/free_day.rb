class FreeDay
  include DataMapper::Resource
  
  property :id, Serial
  property :user_id,     Integer, :nullable => false, :index => true
  property :date,        Date, :nullable => false, :index => true

  belongs_to :user

  def self.is_day_off(user_id, thisday)
    !FreeDay.all(:user_id => user_id, :date => thisday).empty?
  end

end

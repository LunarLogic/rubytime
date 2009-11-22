class FreeDay
  include DataMapper::Resource
  
  property :id, Serial
  property :user_id,     Integer, :nullable => false, :index => true
  property :date,        Date, :nullable => false, :index => true

  belongs_to :user

  def self.is_day_off(user, thisday)
    return false unless user.respond_to? :free_days
    user.free_days.count(:date => thisday) > 0
  end
  
  def self.ranges
    ranges = []
    all.group_by { |free_day| free_day.user }.each do |user, free_days|
      ranges += user_ranges(free_days)
    end
    ranges
  end
  
  def self.to_ical
    cal = Icalendar::Calendar.new
    
    all.ranges.each do |range|
      cal.event do
        dtstart     range[:start_date]
        dtend       range[:end_date] + 1 # DTEND property specifies the non-inclusive end of the event, that's why "+1"
        summary     range[:user].name
      end
    end
    
    cal.to_ical
  end

  private
  
  def self.user_ranges(free_days)
    free_days.sort_by{|fd|fd.date}.inject([]) do |ranges,free_day|
      if ranges.last and ranges.last[:end_date] + 1 == free_day.date
        ranges.last[:end_date] = free_day.date
      else
        ranges << { :start_date => free_day.date, :end_date => free_day.date, :user => free_day.user }
      end
      ranges
    end
  end
  
end
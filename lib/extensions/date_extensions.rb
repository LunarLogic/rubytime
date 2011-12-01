class Date
  
  SUNDAY = 0
  SATURDAY = 6
  
  def weekend?
    wday == SATURDAY or wday == SUNDAY
  end
  
  def weekday?
    not weekend?
  end
  
  def previous_weekday
    day = self - 1
    until day.weekday?
      day -= 1
    end
    day
  end

  def first_day_of_month
    Date.parse("#{year}-#{month}-1")
  end
end

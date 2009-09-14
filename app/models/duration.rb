class Duration < DelegateClass(Fixnum)

  def to_s(s = nil)
    super unless s.nil?    
    format("%d:%.2d", self / 1.hour, (self % 1.hour) / 1.minute)
  end
  
  def +(fixnum)
    Duration.new(super)
  end
  
  def coerce(other)
   return self, other
 end

end

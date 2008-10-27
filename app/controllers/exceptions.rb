class Exceptions < Application
  
  # handle NotFound exceptions (404)
  def not_found
    "not found"
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

  # handle Forbidden exceptins (403)
  def forbidden
    "Permission denied"
  end
  
  def object_not_found_error
    
  end
end
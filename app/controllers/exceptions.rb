class Exceptions < Application
  
  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

  # handle Forbidden exceptins (403)
  def forbidden
    "Permission denied"
  end
end
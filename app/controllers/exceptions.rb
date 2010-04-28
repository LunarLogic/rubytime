class Exceptions < Merb::Controller

  log_params_filtered :password
  
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

  def bad_request
    render "Bad Request", :layout => false
  end
  
  def unauthenticated
    if request.ajax?
      "Permission denied"
    else
      render :template => "../../slices/merb-auth-slice-password/app/views/exceptions/unauthenticated"
    end
  end
  
  def number_of_columns
    1
  end
end

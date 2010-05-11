class MerbAuthSlicePassword::Sessions < MerbAuthSlicePassword::Application

  log_params_filtered :password

  private   
  def redirect_after_logout
    message[:notice] = "Logged Out"
    redirect url(:login), :message => message
  end  
end

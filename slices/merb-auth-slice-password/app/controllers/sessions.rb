class MerbAuthSlicePassword::Sessions < MerbAuthSlicePassword::Application
  private   
  def redirect_after_logout
    message[:notice] = "Logged Out"
    redirect url(:login), :message => message
  end  
end

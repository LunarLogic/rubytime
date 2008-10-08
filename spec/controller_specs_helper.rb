module ControllerSpecsHelper
 
  private
  
  def dispatch_to_as_admin(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, Admin.first, params, &blk)
  end
  
  def dispatch_to_as_employee(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, Employee.first, params, &blk)
  end
  
  def dispatch_to_as_client(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, ClientUser.first, params, &blk)
  end
  
  def dispatch_to_as(controller_klass, action, user, params = {}, &blk)
    dispatch_to(controller_klass, action, params) do |controller|
      controller.stub! :render
      controller.stub!(:current_user).and_return(user)
      blk.call(controller) if block_given?
      controller
    end
  end
  
  def raise_not_found
    raise_error Merb::Controller::NotFound
  end
  
  def raise_forbidden
    raise_error Merb::Controller::Forbidden
  end
end
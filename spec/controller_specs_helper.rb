module ControllerSpecsHelper
 
  private
  
  def prepare_users
    # cleanup db because
    User.all.destroy!
    
    @admin = Employee.make(:admin)
    @employee = Employee.make
    @client_user = ClientUser.make
    @admin.save.should be_true
    @employee.save.should be_true
    @client_user.save.should be_true
    @client = Client.gen
  end
  
  def dispatch_to_as_admin(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, @admin || Employee.admin.first, params, &blk)
  end
  
  def dispatch_to_as_employee(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, @employee || Employee.not_admin.first, params, &blk)
  end
  
  def dispatch_to_as_client(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, @client_user || ClientUser.first, params, &blk)
  end

  def dispatch_to_as_guest(controller_klass, action, params = {}, &blk)
    dispatch_to_as(controller_klass, action, nil, params, &blk)
  end
  
  def dispatch_to_as(controller_klass, action, user, params = {}, &blk)
    # if user.is_a?(String) || user.is_a?(Symbol)
    #   send "dispatch_to_as_#{user}".to_sym, controller_klass, action, params, &blk
    # else
    dispatch_to(controller_klass, action, params) do |controller|
      controller.stub! :render
      controller.stub!(:current_user).and_return(user)
      blk.call(controller) if block_given?
      controller
    end
    # end
  end
  
  def raise_not_found
    raise_error Merb::Controller::NotFound
  end
  
  def raise_forbidden
    raise_error Merb::Controller::Forbidden
  end
end
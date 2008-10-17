module ControllerSpecsHelper
 
  private
  
  def prepare_users
    # cleanup db because
    User.all.destroy!
    
    @admin = Employee.make(:admin)
    @employee = Employee.make
    @client_user = ClientUser.make
    @admin.save.should be_true
    p @admin.errors unless @admin.valid?
    @employee.save.should be_true
    p @employee.errors unless @employee.valid?
    @client_user.save.should be_true
    p @client_user.errors unless @client_user.valid?
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
    dispatch_to(controller_klass, action, params) do |controller|
      controller.stub! :render
      controller.stub!(:current_user).and_return(user)
      blk.call(controller) if block_given?
      controller
    end
  end
  
  def describe_mail(mailer, template, &block) 
    describe "/#{mailer.to_s.downcase}/#{template}" do 
      before :each do 
        @mailer_class, @template = mailer, template 
        @assigns = {} 
      end 
   
      def deliver(send_params={}, mail_params={}) 
        mail_params = {:from => "from@example.com", :to => "to@example.com", :subject => "Subject Line"}.merge(mail_params) 
        @mailer_class.new(send_params).dispatch_and_deliver @template.to_sym, mail_params 
        @mail = Merb::Mailer.deliveries.last 
      end 
   
      instance_eval &block 
    end 
  end 
  
  def raise_not_found
    raise_error Merb::Controller::NotFound
  end
  
  def raise_forbidden
    raise_error Merb::Controller::Forbidden
  end
end
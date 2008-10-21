module ControllerSpecsHelper
 
  private
  
  class As
    def initialize(user, spec)
      @user = case user
              when :admin
                # Employee.admin.first WTF? why it doesn't work sometimes?
                User.first(:admin => true) || raise("There is no admin user in database")
              when :employee
                Employee.not_admin.first || raise("There is employee user in database")
              when :client
                ClientUser.first || raise("There is no client user in database")
              when :guest
                nil
              else 
                user
              end
      @spec = spec
    end
    
    def dispatch_to(controller_klass, action, params = {}, &blk)
      @spec.dispatch_to(controller_klass, action, params) do |controller|
        controller.stub!(:current_user).and_return(@user)
        blk.call(controller) if block_given?
        controller
      end
    end
  end
  
  class BlockMatcher
    def initialize()
      @matchers = []
    end
    
    def and(matcher, &blk)
      @matchers << [:should, matcher]
      run(&blk) if block_given?
    end
    
    def and_not(matcher, &blk)
      @matchers << [:should_not, matcher]
      run(&blk) if block_given?      
    end
    
    private
    
    def run(&blk)
      @matchers.inject(blk) do |memo, matcher|
        proc { memo.send matcher[0], matcher[1] }
      end.call
    end
  end
  
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
  
  def as(user)
    As.new(user, self)
  end

  def block_should(matcher, &blk)
    BlockMatcher.new.and(matcher, &blk)
  end
  
  def block_should_not(matcher, &blk)
    BlockMatcher.new.and_not(matcher, &blk)
  end

  def dispatch_to_as_admin(controller_klass, action, params = {}, &blk)
    as(:admin).dispatch_to(controller_klass, action, params, &blk)
  end
  
  def dispatch_to_as_employee(controller_klass, action, params = {}, &blk)
    as(:employee).dispatch_to(controller_klass, action, params, &blk)
  end
  
  def dispatch_to_as_client(controller_klass, action, params = {}, &blk)
    as(:client).dispatch_to(controller_klass, action, params, &blk)
  end

  def dispatch_to_as_guest(controller_klass, action, params = {}, &blk)
    as(:guest).dispatch_to(controller_klass, action, params, &blk)
  end
  
  def dispatch_to_as(controller_klass, action, user, params = {}, &blk)
    as(user).dispatch_to(controller_klass, action, params)
  end
  
  def describe_mail(mailer, template, &block) 
    describe "/#{mailer.to_s.downcase}/#{template}" do 
      before :each do 
        @mailer_class, @template = mailer, template 
        @assigns = {} 
      end 
   
      def deliver(send_params = {}, mail_params = {}) 
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
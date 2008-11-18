module Rubytime
  module Test
    module ControllerHelper
      private
  
      class As
        def initialize(user, spec)
          @user = case user
                  when :admin
                    # Employee.admin.first WTF? why it doesn't work sometimes?
                    User.first(:admin => true) or raise "There is no admin user in database"
                  when :employee
                    Employee.not_admin.first or raise "There is employee user in database"
                  when :client
                    ClientUser.first or raise "There is no client user in database"
                  when :guest
                    nil
                  else 
                    user
                  end
          @spec = spec
        end
    
        def dispatch_to(controller_klass, action, params = {}, &blk)
          @spec.dispatch_to(controller_klass, action, params) do |controller|
            controller.session.user = @user
            blk.call(controller) if block_given?
            controller
          end
        end
      end # As
  
      def as(user)
        As.new(user, self)
      end
  
      def dispatch_to_as_admin(controller_klass, action, params = {}, &blk)
        Merb.logger <<  "dispatch_to_as_admin is deprecated - user as(:admin).dispatch_to instead"
        as(:admin).dispatch_to(controller_klass, action, params, &blk)
      end
  
      def dispatch_to_as_employee(controller_klass, action, params = {}, &blk)
        Merb.logger <<  "dispatch_to_as_employee is deprecated - user as(:employee).dispatch_to instead"
        as(:employee).dispatch_to(controller_klass, action, params, &blk)
      end
  
      def dispatch_to_as_client(controller_klass, action, params = {}, &blk)
        Merb.logger <<  "dispatch_to_as_client is deprecated - user as(:client).dispatch_to instead"    
        as(:client).dispatch_to(controller_klass, action, params, &blk)
      end

      def dispatch_to_as_guest(controller_klass, action, params = {}, &blk)
        Merb.logger <<  "dispatch_to_as_guest is deprecated - user as(:guest).dispatch_to instead"
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

      def raise_unauthenticated
        raise_error Merb::Controller::Unauthenticated
      end
      
      def raise_bad_request
        raise_error Merb::Controller::BadRequest
      end
    end
  end # Test
end # Rubytime
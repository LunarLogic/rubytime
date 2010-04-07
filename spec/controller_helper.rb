module Rubytime
  module Test
    module ControllerHelper
      private

      class As
        def initialize(user, spec)
          @user = case user
                    when :admin then Employee.generate(:admin)
                    when :employee then Employee.generate
                    when :client then ClientUser.generate
                    when :guest then nil
                    else user
                  end
          @spec = spec
        end

        def dispatch_to(controller_klass, action, params = {}, env = {}, &blk)
          @spec.dispatch_to(controller_klass, action, params, env) do |controller|
            controller.session.user = @user
            blk.call(controller) if block_given?
            controller
          end
        end
      end

      def as(user)
        As.new(user, self)
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
  end
end

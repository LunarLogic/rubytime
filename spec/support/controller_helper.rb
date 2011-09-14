module Rubytime
  module Test
    module ControllerHelper
      def login(user = nil)
        before do
          @current_user = case user
                          when :admin then Employee.generate(:admin)
                          when :employee then Employee.generate
                          when :client then ClientUser.generate
                          when :inactive_user then Employee.generate(:active => false)
                          when :guest then nil
                          else user
                        end
          sign_in(@current_user) if @current_user
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
  end
end

module Rubytime
  module Test
    module ControllerHelper
      module ClassMethods
        def login(user = nil)
          before do
            login(user)
          end
        end
      end

      def login(user)
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
  end
end

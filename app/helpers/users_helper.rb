module Merb
  module UsersHelper
    def link_to_calendar(user)
      link_to "Calendar", url(:user_calendar, user) if user.is_employee?
    end
  end
end # Merb
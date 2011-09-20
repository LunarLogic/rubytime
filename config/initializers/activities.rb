module Rubytime
  class Application < Rails::Application
    config.after_initialize do
      Rubytime::Misc.check_activity_roles
    end
  end
end
    

require Merb.root / "lib/rubytime/authenticated_system"

class Application < Merb::Controller
  include Utype::AuthenticatedSystem
end
class Application < Merb::Controller
  before :ensure_authenticated
  before :set_api_version_header

  JSON_API_VERSION = 1  # see CHANGELOG-API.txt

  def current_user
    session.user
  end
  
  private

  def self.protect_fields_for(record, fields = {})
    if fields[:in]
      before(nil, :only => fields[:in]) do |c|
        c.params[record] ||= {}
        fields_to_delete = []
        fields_to_delete += fields[:always] if fields[:always]
        fields_to_delete += fields[:admin] if fields[:admin] && !c.current_user.is_admin?
        fields_to_delete.each { |f| c.params[record].delete(f) }
      end
    end
  end

  def ensure_admin
    raise Forbidden unless current_user.is_admin?
  end

  def ensure_not_client_user
    raise Forbidden if current_user.is_client_user?
  end
  
  def ensure_user_that_can_manage_financial_data
    raise Forbidden unless current_user.can_manage_financial_data?
  end
  
  def render_success(content = "", status = 200)
    render content, :layout => false, :status => status 
  end
  
  def render_failure(content = "", status = 400)
    render content, :layout => false, :status => status
  end
  
  def number_of_columns
    2
  end

  def client_api_version
    request.env["HTTP_X_API_VERSION"].to_i
  end

  def set_api_version_header
    if request.env["HTTP_X_API_VERSION"]
      headers["X-API-Version"] = JSON_API_VERSION.to_s
    end
  end

  def send_api_version_error
    render_failure("", 412) # :precondition_failed
  end

end

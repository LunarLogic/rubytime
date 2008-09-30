# Using authentication from Utype
# http://github.com/mariusz/utype/tree/master

module Utype
  module AuthenticatedSystem
    protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != nil
    end

    # Accesses the current user from the session.  Set it to nil if login fails
    # so that future calls do not hit the database.
    def current_user
      @current_user ||= (login_from_session || login_from_params || nil)
    end

    # Store the given user in the session.
    def current_user=(new_user)
      session[:user_id] = new_user.is_a?(User) ? new_user.id : nil
      @current_user = new_user
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || throw(:halt, :access_denied)
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      case content_type
      when :html
        store_location
        redirect url(:login)
      when :xml
        headers["Status"]             = "Unauthorized"
        headers["WWW-Authenticate"]   = %(Basic realm="Web Password")
        set_status(401)
        render :text => "Couldn't authenticate you"
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      loc = session[:return_to] || default
      session[:return_to] = nil
      redirect loc
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    # def self.included(base)
    #   base.send :helper_method, :current_user, :logged_in?
    # end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      if session[:user_id]
        u = User.first(:id => session[:user_id])
        self.current_user = u
      end
    end

    def login_from_params
      if params[:login] && params[:password]
        u = User.authorize(params[:login], params[:password])
        self.current_user = u
      end
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    #def login_from_basic_auth
    #  username, passwd = get_auth_data
    #  self.current_user = User.authenticate(username, passwd) if username && passwd
    #end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    #def login_from_cookie     
    #  user = cookies[:auth_token] && User.first(:remember_token => cookies[:auth_token])
    #  if user && user.remember_token?
    #    user.remember_me
    #    cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
    #    self.current_user = user
    #  end
    #end

    def reset_session
      session.data.each{|k,v| session.data.delete(k)}
    end

    private
      @@http_auth_headers = %w(Authorization HTTP_AUTHORIZATION X-HTTP_AUTHORIZATION X_HTTP_AUTHORIZATION REDIRECT_X_HTTP_AUTHORIZATION)

      # gets BASIC auth info
      def get_auth_data
        auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
        auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
        return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
      end
    end
end
# This file is specifically for you to define your strategies 
#
# You should declare you strategies directly and/or use 
# Merb::Authentication.activate!(:label_of_strategy)
#
# To load and set the order of strategy processing

Merb::Authentication.activate!(:default_password_form)
Merb::Authentication.activate!(:default_basic_auth)

module Merb::Authentication::Strategies
  class CookieStrategy < Merb::Authentication::Strategy
    def run!
       if cookies[:remember_me_token]
         User.authenticate_with_token(cookies[:remember_me_token])
       end
    end
  end
end

module Merb::Authentication::Strategies
  class PasswordFormWithTokenStrategy < Merb::Authentication::Strategies::Basic::Form
    def run!
      user = super
      if user && params[:remember_me] == "1"
        user.remember_me!
        cookies.set_cookie('remember_me_token', user.remember_me_token, :expires => user.remember_me_token_expiration.to_time)
      end
      user
    end
  end
end

Merb::Authentication.default_strategy_order = [Merb::Authentication::Strategies::CookieStrategy, Merb::Authentication::Strategies::PasswordFormWithTokenStrategy, Merb::Authentication::Strategies::Basic::BasicAuth]
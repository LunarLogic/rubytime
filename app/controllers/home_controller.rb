class HomeController < ApplicationController

  skip_before_filter :authenticate_user!

  def index
    if current_user
      redirect_to activities_path
    else
      redirect_to new_user_session_path
    end
  end

end

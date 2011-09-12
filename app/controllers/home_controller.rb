class HomeController < ApplicationController

  skip_before_filter :authenticate_user!

  def index
    if current_user
      redirect resource(:activities)
    else
      redirect new_user_session_path
    end
  end

end

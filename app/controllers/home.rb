class Home < Application

  skip_before :ensure_authenticated

  def index
    if current_user
      redirect resource(:activities)
    else
      redirect url(:login)
    end
  end

end

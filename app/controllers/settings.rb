class Settings < Application

  before :ensure_admin

  def edit
    only_provides :html
    @setting = Setting.get
    raise NotFound unless @setting
    display @setting
  end

  def update
    @setting = Setting.get
    raise NotFound unless @setting
    if @setting.update(params[:setting])
      redirect url(:edit_settings)
    else
      display @setting, :edit
    end
  end

end # Settings

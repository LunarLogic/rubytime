class SettingsController < ApplicationController

  before_filter :ensure_admin

  respond_to :html

  def edit
    @setting = Setting.get
    not_found and return unless @setting
    respond_with @setting
  end

  def update
    @setting = Setting.get
    not_found and return unless @setting
    if @setting.update(params[:setting])
      redirect_to edit_settings_path
    else
      render :edit
    end
  end

  def number_of_columns
    1
  end

end # Settings

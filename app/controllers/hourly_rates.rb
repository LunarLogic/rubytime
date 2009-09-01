class HourlyRates < Application
  
  before :ensure_admin_or_project_manager
  
  only_provides :json

  def index
    @project = Project.get(params[:project_id])
    @hourly_rates = @project.hourly_rates_grouped_by_roles.keys.sort_by{|role|role.name}.map do |role|
      { :project_id => @project.id, 
        :role_id => role.id, 
        :role_name => role.name, 
        :hourly_rates => @project.hourly_rates_grouped_by_roles[role].each{|hr|hr.date_format_for_json = current_user.date_format}
      }
    end
    display @hourly_rates
  end

  def create
    @hourly_rate = HourlyRate.new(params[:hourly_rate])
    @hourly_rate.operation_author = current_user
    if @hourly_rate.save
      @hourly_rate.date_format_for_json = current_user.date_format
      display :status => :ok, :hourly_rate => @hourly_rate
    else
      display :status => :invalid, :hourly_rate => { :error_messages => @hourly_rate.error_messages }
    end
  end

  def update
    @hourly_rate = HourlyRate.get(params[:id])
    raise NotFound unless @hourly_rate
    @hourly_rate.operation_author = current_user
    if @hourly_rate.update_attributes(params[:hourly_rate])
      @hourly_rate.date_format_for_json = current_user.date_format
      display :status => :ok, :hourly_rate => @hourly_rate
    else
      display :status => :invalid, :hourly_rate => { :error_messages => @hourly_rate.error_messages }
    end
  end

  def destroy
    @hourly_rate = HourlyRate.get(params[:id])
    raise NotFound unless @hourly_rate
    @hourly_rate.operation_author = current_user
    if @hourly_rate.destroy
      display :status => :ok
    else
      raise InternalServerError
    end
  end

end # HourlyRates

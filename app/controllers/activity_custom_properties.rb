class ActivityCustomProperties < Application
  
  before :ensure_admin
  before :load_activity_custom_property, :only => [:edit, :update, :destroy]

  def index
    @new_activity_custom_property = ActivityCustomProperty.new
    @activity_custom_properties = ActivityCustomProperty.all
    display @activity_custom_properties  
  end
  
  def create
    @new_activity_custom_property = ActivityCustomProperty.new(params[:activity_custom_property])
    if @new_activity_custom_property.save
      redirect resource(:activity_custom_properties), 
        :message => {:notice => "Custom property was successfully created"}
    else
      @activity_custom_properties = ActivityCustomProperty.all
      render :index
    end
  end
  
  def edit
    display @activity_custom_property
  end
  
  def update
    if @activity_custom_property.update(params[:activity_custom_property])
      redirect resource(:activity_custom_properties), 
        :message => {:notice => "Custom property was successfully created"}
    else
      render :edit
    end
  end
  
  def destroy
    if @activity_custom_property.destroy
      redirect resource(:activity_custom_properties), 
        :message => {:notice => "Custom property was successfully deleted"}
    else
      redirect resource(:activity_custom_properties), 
        :message => {:error => "Unable to delete"}
    end
  end
  
  protected
  
  def load_activity_custom_property
    @activity_custom_property = ActivityCustomProperty.get(params[:id]) or raise NotFound
  end
  
  def number_of_columns
    ["edit", "update"].include?(params[:action]) ? 1 : super
  end

end

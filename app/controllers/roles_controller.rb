class RolesController < ApplicationController
  before_filter :ensure_admin
  before_filter :load_roles, :only => [:index, :create]

  respond_to :html, :json
  
  def index
    @role = Role.new
    respond_with @roles
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to roles_path
    else
      render :index
    end
  end
  
  def edit
    @role = Role.get!(params[:id])
    render
  end
  
  def update
    @role = Role.get!(params[:id])

    if @role.update(params[:role]) || !@role.dirty?
      redirect_to roles_path
    else
      render :edit
    end
  end
  
  def destroy
    @role = Role.get!(params[:id])

    if @role.destroy
      render_success
    else
      render_failure "Users with this role exist. Couldn't delete."
    end
  end

  protected
  def load_roles
    @roles = Role.all(:order => [:name])
  end
  
  def number_of_columns
    params[:action] == "edit" ? 1 : super
  end
end # Roles

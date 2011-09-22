class UsersController < ApplicationController
  respond_to :json, :html #,:xml, :yaml, :js

  before_filter :authenticate_user!, :except => [:request_password, :reset_password]
  before_filter :ensure_admin, :only => [:new, :create, :edit, :destroy, :index]
  before_filter :load_user, :only => [:edit, :update, :show, :destroy, :settings] 
  before_filter :load_users, :only => [:index, :create]
  before_filter :load_clients_and_roles, :only => [:index, :create, :edit, :update]
  before_filter :check_authorization, :only => [:edit, :update, :show, :settings]

  protect_fields_for :user, :in => [:update],
    :always => [:activities_count],
    :admin => [:role_id, :client_id, :login, :active, :admin, :type, :class_name]

  def index
    @user = if params[:client_id]
              ClientUser.new :client => Client.get(params[:client_id])
            else
              Employee.new
            end
            
    respond_with @users
  end

  def with_activities
    @users = if current_user.is_admin?
               Employee.all(:order => [:name]).with_activities
             elsif current_user.is_client_user?
               Employee.all(:order => [:name]).with_activities_for_client(current_user.client)
             else
               forbidden and return
             end
    respond_to do |format|
      format.json { render :json => @users }
    end
  end

  def show
    respond_with @user
  end

  def edit
    respond_to do |format|
      format.html { render }
    end
  end

  def create
    class_name = params[:user].delete(:class_name)
    @user = (class_name == "Employee" ? Employee : ClientUser).new(params[:user])
    if @user.save
      redirect_to user_path(@user)
    else
      render :index
    end
  end

  def update
    class_name = params[:user].delete(:class_name)
    klass = Object.const_get(class_name) if ['Employee', 'ClientUser'].include?(class_name)
    @user.attributes = params[:user]
    if klass && klass != @user.type
      @user = @user.becomes(klass)
    end
    if @user.save || !@user.dirty?
      if current_user.is_admin?
        redirect_to user_path(:id => @user.id), :notice => "User has been updated"
      else
        redirect_to activities_path, :notice => "Your account information has been updated"
      end
    else
      render(current_user.is_admin? ? :edit : :settings)
    end
  end

  def destroy
    if @user.destroy
      render_success
    else
      render_failure "Couldn't delete user which has activities"
    end
  end
  
  def settings
    render
  end

  # Returns all users matching current selected roles
  def with_roles
    forbidden and return unless current_user.is_admin? || current_user.is_client_user?

    @search_criteria = SearchCriteria.new(params[:search_criteria], current_user)
    render :json => 
      {:options => @search_criteria.all_users.map { |u| { :id => u.id, :name => u.name } } }
  end
  
  def request_password
    if params[:email]
      user = User.first(:email => params[:email])
      if user
        user.generate_password_reset_token
        redirect_to new_user_session_path,
          :message => { :notice => "Email with password reset link has been sent to #{params[:email]}" }
      else
        redirect_to users_request_password_path,
          :message => { :error => "Couldn't find user with email #{params[:email]}" }
      end
    else
      render
    end
  end
  
  def reset_password
    bad_request and return unless token = params[:token]
    not_found and return unless user = User.first(:password_reset_token => token)
    if user.password_reset_token_exp < DateTime.now
      redirect_to request_password_users_path, :message => { :notice => "Password reset token has expired" }
    else
      sign_in(:user, user)
      user.clear_password_reset_token!
      redirect_to settings_user_path(user), :message => { :notice => "Please set your password" }
    end
  end
  
  # this is for API, to let the client check if credentials are correct
  def authenticate
    render(:json => current_user, :methods => [:user_type])
  end
    
  
protected

  def load_users
    @users = User.all(:order => [:name])
  end
  
  def load_user
    not_found and return unless @user = User.get(params[:id]) 
  end
  
  def load_clients_and_roles
    @clients = Client.active.all(:order => [:name])
    @roles = Role.all(:order => [:name])
  end

  def check_authorization
    forbidden and return unless @user.editable_by?(current_user)
  end
  
  def number_of_columns
    params[:action] == "show" || params[:action] == "settings" || params[:action] == "edit" ? 1 : super
  end
end # Users

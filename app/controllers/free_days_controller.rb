class FreeDaysController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter :authenticate_user!, :except => [:index]
  before_filter :prepare_source, :except => [:index]

  def index
    forbidden and return unless params[:access_key] == Setting.free_days_access_key
    respond_to do |format|
      format.ics {render :text => FreeDay.to_ical}
    end
  end

  def create
    @free_day = @free_days.new :date => params[:date]
    if @free_day.save
      render_success "You have just taken vacation at #{@free_day.date}"
    else
      render_failure "Couldn't take vacation"
    end
  end

  # note: it's a collection style action, because we identify the FreeDay by :date, not by its record id
  def delete
    @free_day = @free_days.first :date => params[:date]
    if @free_day && @free_day.destroy
      render_success "Vacation at #{params[:date]} was removed"
    else
      render_failure "Couldn't remove vacation"
    end
  end


  private

  def prepare_source
    user = (current_user.admin? && params[:user_id].present?) ? Employee.get!(params[:user_id]) : current_user
    @free_days = user.free_days
  end
end

class FreeDaysController < ApplicationController

  before :ensure_authenticated, :exclude => [:index]
  before :prepare_source, :exclude => [:index]

  def index
    only_provides :ics
    raise Forbidden unless params[:access_key] == Setting.free_days_access_key
    render FreeDay.to_ical
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
    user = Employee.get(params[:user_id]) if current_user.admin? && !params[:user_id].blank?
    user ||= current_user
    @free_days = user.free_days
  end

end

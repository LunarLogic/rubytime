class FreeDays < Application

  before :ensure_authenticated, :exclude => [:index]

  def index
    only_provides :ics
    raise Forbidden unless params[:access_key] == Setting.free_days_access_key
    render FreeDay.to_ical
  end

  def create
    @free_day = current_user.free_days.new :date => params[:date]
    if @free_day.save
      render_success "You have just taken vacation at #{@free_day.date}"
    else
      render_failure "Couldn't take vacation"
    end
  end

  # note: it's a collection style action, because we identify the FreeDay by :date, not by its record id
  def delete
    @free_day = current_user.free_days :date => params[:date]
    if !@free_day.empty? && @free_day.destroy!
      render_success "Vacation at #{params[:date]} was removed"
    else
      render_failure "Couldn't remove vacation"
    end
  end

end

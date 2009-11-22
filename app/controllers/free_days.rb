# TODO: dry up, make it RESTful, add JSON API - solnic
class FreeDays < Application
  before :ensure_authenticated, :exclude => [:index]

  def index
    only_provides :ics
    
    raise Forbidden unless params[:access_key] == Setting.free_days_access_key
    
    render FreeDay.to_ical
  end

  def new
    @free_day = current_user.free_days.new(:date => params[:date])
      
    if @free_day.save
      render_success "You have just taken vacation at #{@free_day.date}"
    else
      render_failure "Couldn't take vacation"
    end
  end

  
  def delete
    @free_day = current_user.free_days(:date => params[:date])

    if @free_day.destroy!
      render_success "Vacation at #{params[:date]} was removed"
    else
      render_failure "Couldn't remove vacation"
    end
  end
end

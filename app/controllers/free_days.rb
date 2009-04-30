class FreeDays < Application


  def new
    date = params[:date]
    user_id = params[:user_id]
    if current_user.id.to_s == user_id or current_user.is_admin?
      @free_day = FreeDay.new(:user_id => user_id, :date => date)
      if @free_day.save
        render_success "You have taken vacation at " + date
      else
        render_failure "Couldn't take vacation"
      end
    end
    
  end

  def delete
    date = params[:date]
    user_id = params[:user_id]
    if current_user.id == user_id or current_user.is_admin?
      @free_day = FreeDay.all(:user_id => user_id, :date => date)
      if @free_day.destroy!
        render_success "You have remove vacation at " + date
      else
        render_failure "Couldn't remove vacation"
      end
    end
  end
  
end

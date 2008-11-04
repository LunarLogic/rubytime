class UserMailer < Merb::MailController
  def welcome
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
  
  def password_reset_link
    @user = params[:user]
    @url = Rubytime::CONFIG[:site_url]
    render_mail
  end
end

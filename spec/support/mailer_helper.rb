module Rubytime
  module Test
    module MailerHelper
      def clear_mail_deliveries
        ActionMailer::Base.deliveries.clear
      end

      def last_delivered_mail
        ActionMailer::Base.deliveries.last
      end

      def deliver(action, mail_params = {}, send_params = {})
        mailer_params = { :from => "no-reply@webapp.com", :to => "recepient@person.com" }
        mailer_params.update(mail_params)
        mailer_params.update(send_params)
        UserMailer.send(action, mailer_params)
        @delivery = last_delivered_mail
      end
    end
  end
end

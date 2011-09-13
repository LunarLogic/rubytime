module Rubytime
  module Test
    module MailerHelper
      # Helper to clear mail deliveries.
      def clear_mail_deliveries
        ActionMailer::Base.deliveries.clear
      end

      # Helper to access last delivered mail.
      # In test mode merb-mailer puts email to
      # collection accessible as Merb::Mailer.deliveries.
      def last_delivered_mail
        ActionMailer::Base.deliveries.last
      end

      # Helper to deliver
      def deliver(action, mail_params = {}, send_params = {})
        mailer_params = { :from => "no-reply@webapp.com", :to => "recepient@person.com" }.
          merge(mail_params).merge(send_params)
        UserMailer.send(action, mailer_params)
        @delivery = last_delivered_mail
      end
    end
  end
end

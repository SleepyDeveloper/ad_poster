module MailgunHelper
  require 'mailgun'
  extend self

  def send_message(**email_parameters)
    mailgun = Mailgun(api_key: ENV['MAILGUN_API_KEY'], domain: ENV['MAILGUN_DOMAIN'])
    email_parameters = default_email_params.merge email_parameters
    mailgun.messages.send_email(email_parameters)
  end

  def default_email_params
    {
      from: "no-reply@#{ENV['MAILGUN_DOMAIN']}",
    }
  end
end

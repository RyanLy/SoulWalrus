require 'twilio-ruby'

account_sid = ENV['TWILIO_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']

Twilio.configure do |config|
  config.account_sid = account_sid
  config.auth_token = auth_token
end

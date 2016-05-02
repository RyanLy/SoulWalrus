require 'pusher'

Pusher.app_id = '202250'
Pusher.key = 'f35ce6a52f1fc2a358fa'
Pusher.secret = ENV["PUSHER_SECRET"]
Pusher.logger = Rails.logger
Pusher.encrypted = true

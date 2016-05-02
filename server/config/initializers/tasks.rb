require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '5m' do
  p "Running Twitch live helper"
  Api::V1::StreamerController.getLiveHelper
end

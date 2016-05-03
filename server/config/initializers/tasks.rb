require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1m' do
  Api::V1::StreamerController.getLiveHelper
end

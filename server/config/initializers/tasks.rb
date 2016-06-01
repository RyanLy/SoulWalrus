require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '90s' do
  Api::V1::StreamerController.getLiveHelper
end

scheduler.every '1m' do
  Api::V1::CsgoController.pollLobby
end

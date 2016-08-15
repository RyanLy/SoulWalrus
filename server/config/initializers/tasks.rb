require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '90s' do
  Api::V1::StreamerController.getLiveHelper
end

scheduler.every '1m' do
  Api::V1::CsgoController.pollLobby
end

scheduler.every '30s' do
  generated = Random.rand(1)
  # p "Try to create a point: #{generated}"
  if generated == 0
    # p 'Creating a point'
    Api::V1::PointController.create_points
  end
end

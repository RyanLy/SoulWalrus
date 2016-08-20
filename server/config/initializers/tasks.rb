require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '90s' do
  Api::V1::StreamerController.getLiveHelper
end

scheduler.every '1m' do
  Api::V1::CsgoController.pollLobby
end

scheduler.every '30s' do
  generated = Random.rand(120)
  p "Try to create a point: #{generated}"
  if generated == 0
    p 'Creating a point'
    Api::V1::PointController.create_points
  end
end

scheduler.cron '00 06 * * *' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "1 hour until tourney is over."
  })
end

scheduler.cron '00 07 * * *' do
  Api::V1::PokeShuffleController.end_tourney
  Api::V1::PokeShuffleController.start_tourney
end

scheduler.cron '00 14 * * *' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "1 hour until tourney is over."
  })
end

scheduler.cron '00 15 * * *' do
  Api::V1::PokeShuffleController.end_tourney
  Api::V1::PokeShuffleController.start_tourney
end

scheduler.cron '00 22 * * *' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "1 hour until tourney is over."
  })
end

scheduler.cron '00 23 * * *' do
  Api::V1::PokeShuffleController.end_tourney
  Api::V1::PokeShuffleController.start_tourney
end

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '90s' do
  Api::V1::StreamerController.getLiveHelper
end

scheduler.every '1m' do
  Api::V1::CsgoController.pollLobby
end

if Rails.env.development?
  scheduler.every '30s' do
    Api::V1::PointController.create_points
    Api::V1::PokeShuffleController.end_tourney
    Api::V1::PokeShuffleController.start_tourney
  end
end

scheduler.every '30s' do
  generated = Random.rand(120)
  p "Try to create a point: #{generated}"
  if generated == 0
    p 'Creating a point'
    Api::V1::PointController.create_points
  end
end

scheduler.cron '00 23 * * * America/New_York' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "1 hour until tourney is over. tourney-status to check on current status."
  })
end

scheduler.cron '45 23 * * * America/New_York' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "15 minutes until tourney is over. tourney-status to check on current status."
  })
end

scheduler.cron '00 00 * * * America/New_York' do
  Api::V1::PokeShuffleController.end_tourney
  Api::V1::PokeShuffleController.start_tourney
end

scheduler.cron '00 07 * * * America/New_York' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "1 hour until tourney is over.  tourney-status to check on current status."
  })
end

scheduler.cron '45 07 * * * America/New_York' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "15 minutes until tourney is over. tourney-status to check on current status."
  })
end

scheduler.cron '00 08 * * * America/New_York' do
  Api::V1::PokeShuffleController.end_tourney
  Api::V1::PokeShuffleController.start_tourney
end

scheduler.cron '00 15 * * * America/New_York' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "1 hour until tourney is over.  tourney-status to check on current status."
  })
end

scheduler.cron '45 15 * * * America/New_York' do
  Pusher.trigger('poke_shuffle', 'tourney_reminder', {
    result: "15 minutes until tourney is over. tourney-status to check on current status."
  })
end

scheduler.cron '00 16 * * * America/New_York' do
  Api::V1::PokeShuffleController.end_tourney
  Api::V1::PokeShuffleController.start_tourney
end

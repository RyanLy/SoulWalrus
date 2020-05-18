class CacheLeaderboard
  include SuckerPunch::Job

  def perform
    Api::V1::PointController.refresh_and_cache_leaderboard
  end
end

class CacheRecent
  include SuckerPunch::Job

  def perform
    Api::V1::PointController.refresh_and_cache_recent
  end
end

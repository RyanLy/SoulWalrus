module Api::V1
  class PointController < ApiController

    def index
      all_users = Point.all.collect { |x| (x['user'] and x['user']['name']) || 'Not Claimed' }.sort
      result = {}
      all_users.each do |user|
        result[user] = 0 if result[user].nil?
        result[user] += 1
      end
      render_and_log_to_db(json: {result: result}, status: 200)
    end

    def create
      render_and_log_to_db(json: {error: 'Non-existent secret'}, status: 400) unless allowed_params['point_secret']
      
      if allowed_params['point_secret'] == ENV['POINT_SECRET']
        point = Point.new(
          :user => nil,
          :description => 'Points v1'
        )
        point.save
        render_and_log_to_db(json: {result: point}, status: 200)
      end
    end
    
    def update
      render_and_log_to_db(json: {error: 'Please specify a chatid'}, status: 400) unless allowed_params['user']
      render_and_log_to_db(json: {error: 'Non-existent secret'}, status: 400) unless allowed_params['point_secret']
      render_and_log_to_db(json: {error: 'Please specify an point_id'}, status: 400) unless allowed_params['point_id']
      
      if allowed_params['point_secret'] == ENV['POINT_SECRET']
        point = Point.find(allowed_params['point_id'])

        if !point
          render_and_log_to_db(json: {error: 'Invalid point id. Nice try...'}, status: 400)
        elsif point['user'].nil?
          point.user = allowed_params['user']
          point.save
          render_and_log_to_db(json: {result: point}, status: 200)
        else
          render_and_log_to_db(json: {error: "This point has already been taken by #{point['user']['name']}."}, status: 400)
        end
      end
    end
    
    def self.create_points
      point = Point.new(
        :user => nil,
        :description => 'Points v1'
      )
      point.save
      Pusher.trigger('point', 'point_created', {
        result: point
      })
    end
    
    private
    
    def allowed_params
      params.permit([
        [user: [:id, :name]],
        :point_secret,
        :point_id
      ])
    end
  end
end

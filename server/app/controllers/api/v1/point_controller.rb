module Api::V1
  class PointController < ApiController

    def index
      all_users = Point.all.collect { |x| x['user_name'] || 'Not Claimed' }.sort
      result = {}
      all_users.each do |user|
        result[user] = 0 if result[user].nil?
        result[user] += 1
      end
      render_and_log_to_db(json: {result: result}, status: 200)
    end
    
    def leaderboard
      result = {}
      Point.all.each do |point|
        user_name = point['user_name'] || 'Not Claimed'
        if result[user_name].nil?
          result[user_name] = {}
          result[user_name]['points'] = 0
        end

        if result[user_name]['best_pokemon'].nil? or point['friendly_id'].to_i > result[user_name]['best_pokemon']['friendly_id'].to_i
          result[user_name]['best_pokemon'] = point
        end
        
        result[user_name]['points'] += 1
      end
      render_and_log_to_db(json: {result: result}, status: 200)
    end
    
    
    def get_most_recent
      points = Point.all.sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end

      render_and_log_to_db(json: {result: points[0..4]}, status: 200)
    end
    
    def get_user
      points = Point.where(user_name: allowed_params['user_name']).all.sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end
      
      if points
        render_and_log_to_db(json: {result: points}, status: 200)
      else
        render_and_log_to_db(json: {error: 'Nothing found.'}, status: 400)
      end
    end
    
    def get_pokemon
      points = Point.where(friendly_id: params['friendly_id']).all.sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end
      
      if points
        render_and_log_to_db(json: {result: points}, status: 200)
      else
        render_and_log_to_db(json: {error: 'Nothing found.'}, status: 400)
      end
    end

    def create
      render_and_log_to_db(json: {error: 'Non-existent secret'}, status: 400) unless allowed_params['point_secret']
      
      if allowed_params['point_secret'] == ENV['POINT_SECRET']
        point = Point.new(
          user: nil,
          user_name: nil,
          user_id: nil,
          description: 'Points v1',
          create_date: DateTime.now
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
        point = Point.find_by_id(allowed_params['point_id'])
        # TODO: Fix race condition
        if !point
          render_and_log_to_db(json: {error: 'Invalid point id. Nice try...'}, status: 400)
        elsif point.user.nil?
          point.user = allowed_params['user']
          point.user_name = allowed_params['user']['name']
          point.user_id = allowed_params['user']['id']
          point.capture_date = DateTime.now
          if Point.find_by_id(allowed_params['point_id']).user.nil?
            point.save
            Pusher.trigger('point', 'point_updated', {
              result: point
            })
            render_and_log_to_db(json: {result: point}, status: 200)
          else
            render_and_log_to_db(json: {error: "This point has already been taken by #{point['user']['name']}."}, status: 400)
          end

        else
          render_and_log_to_db(json: {error: "This point has already been taken by #{point['user']['name']}."}, status: 400)
        end
      end
    end
    
    def self.create_points
      c = 2*Random.rand(151*(151+1)/2)
      n = 152 - ((1 + Math.sqrt(1**2 + 4*c))/2).to_int
      
      p "Spin to win: #{n}"
      point = Point.new(
        user: nil,
        user_name: nil,
        user_id: nil,
        description: 'Points v1',
        create_date: DateTime.now,
        friendly_id: n,
        friendly_name: Pokemon.pokemon_info[n-1][:name].capitalize
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
        :point_id,
        :user_id,
        :user_name
      ])
    end
  end
end

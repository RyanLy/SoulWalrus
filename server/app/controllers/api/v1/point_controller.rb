module Api::V1
  class PointController < ApiController
    
    @@point_update_mutex = Mutex.new

    def index
      result = {}
      Point.eval_limit(10000).batch(2500).reject{ |u| u['user_name'] == '_prize' }.each do |point|
        user_name = point['user_name'] || 'Not Claimed'
        user_id = point['user_id'] || 'Not Claimed'
        
        if result[user_id].nil?
          result[user_id] = {}
          result[user_id]['user_name'] = user_name
          result[user_id]['points'] = 0
        end
        
        result[user_id]['points'] += 1
      end
      render_and_log_to_db(json: { result: Hash[result.sort_by {|_key, value| value['points'].to_int}.reverse] }, status: 200)
    end
    
    def leaderboard
      result = {}
      Point.eval_limit(10000).batch(2500).reject{ |u| u['user_name'] == '_prize' }.each do |point|
        user_name = point['user_name'] || 'Not Claimed'
        user_id = point['user_id'] || 'Not Claimed'
        
        if result[user_id].nil?
          result[user_id] = {}
          result[user_id]['user_name'] = user_name
          result[user_id]['points'] = 0
          result[user_id]['poke_value'] = 0
        end

        if result[user_id]['best_pokemon'].nil? or point['friendly_id'].to_i > result[user_id]['best_pokemon']['friendly_id'].to_i
          result[user_id]['best_pokemon'] = point
        end
        
        result[user_id]['points'] += 1
        result[user_id]['poke_value'] += point['friendly_id'].to_i
      end
      render_and_log_to_db(json: {result: Hash[result.sort_by {|_key, value| value['poke_value'].to_int}.reverse]}, status: 200)
    end
    
    
    def get_most_recent
      points = Point.eval_limit(10000).batch(2500).reject{ |u| u['user_name'] == '_prize' }.sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end

      render_and_log_to_db(json: {result: points[0..4]}, status: 200)
    end
    
    def get_user
      points = Point.eval_limit(10000).batch(2500).where(user_name: allowed_params['user_name']).sort_by do |point|
        [point.value.to_i, point.capture_date.to_i]
      end.reverse
      
      if points
        render_and_log_to_db(json: {result: points[0..100]}, status: 200)
      else
        render_and_log_to_db(json: {error: 'Nothing found.'}, status: 400)
      end
    end
    
    def get_pokemon
      points = Point.eval_limit(10000).batch(2500).where(friendly_id: params['friendly_id']).all
                    .reject{ |u| u['user_name'] == '_prize' }.sort do |a, b|
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
      else
        render_and_log_to_db(json: {error: "Please enter a valid secret."}, status: 400)
      end
    end
    
    def update
      render_and_log_to_db(json: {error: 'Please specify a chatid'}, status: 400) unless allowed_params['user']
      render_and_log_to_db(json: {error: 'Non-existent secret'}, status: 400) unless allowed_params['point_secret']
      render_and_log_to_db(json: {error: 'Please specify an point_id'}, status: 400) unless allowed_params['point_id']
      
      if allowed_params['point_secret'] == ENV['POINT_SECRET']
        @@point_update_mutex.synchronize do
          point = Point.find_by_id(allowed_params['point_id'])
          if !point
            render_and_log_to_db(json: {error: 'Invalid point id. Nice try...'}, status: 400)
          elsif point.user.nil?
            point.user = allowed_params['user']
            point.user_name = allowed_params['user']['name']
            point.user_id = allowed_params['user']['id']
            point.capture_date = DateTime.now
            point.save
            Pusher.trigger('point', 'point_updated', {
              result: point
            })
            render_and_log_to_db(json: {result: point}, status: 200)
          else
            render_and_log_to_db(json: {error: "This #{point['friendly_name']} has already been captured by #{point['user']['name']}."}, status: 400)
          end
        end
      else
        render_and_log_to_db(json: {error: "Please enter a valid secret."}, status: 400)
      end
    end
    
    def self.get_id_weight(id)
      if id > 151
        (id - 151) * 151.0/100
      else
        id
      end
    end
    
    def self.create_points
      c = 2*Random.rand(151.0*(151+1)/2)
      n = 152 - ((1 + Math.sqrt(1**2 + 4*c))/2)

      if Random.rand > 0.5
        n = (n * 100.0/151 + 151).to_int
      else
        n = n.to_int
      end
      
      point = Point.create(
        user: nil,
        user_name: nil,
        user_id: nil,
        description: 'Points v1',
        create_date: DateTime.now,
        friendly_id: n,
        value: self.get_id_weight(n),
        friendly_name: Pokemon.pokemon_info[n-1][:name].capitalize
      )
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

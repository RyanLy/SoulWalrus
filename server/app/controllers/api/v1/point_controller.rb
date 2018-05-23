module Api::V1
  class PointController < ApiController
    
    @@point_update_mutex = {}

    def index
      result = {}

      User.all.reject{ |u| u['user_id'] == '-1' }.each do |user|
        user_name = user[:user_name] || 'Not Claimed'
        user_id = user[:user_id] || 'Not Claimed'
        result[user_id] = {
          "user_name" => user_name,
          "points" => user[:points].values.inject(0) {|sum, val| sum + val.length}
        }
      end
      render_and_log_to_db(json: { result: Hash[result.sort_by {|_key, value| value['points'].to_int}.reverse] }, status: 200)
    end
      
    def self.refresh_and_cache_leaderboard
      result = {}

      User.all.reject{ |u| u['user_id'] == '-1' }.each do |user|
        user_name = user[:user_name] || 'Not Claimed'
        user_id = user[:user_id] || 'Not Claimed'


        best_pokmemon_id = self.get_best_pokemon(user[:points])
        best_pokemon = self.create_point_obj(best_pokmemon_id)

        result[user_id] = {
          "user_name" => user_name,
          "points" => user[:points].values.inject(0) {|sum, val| sum + val.length},
          "poke_value" => self.calculate_points(user[:points]),
          "best_pokemon" => best_pokemon
        }
      end

      # Point.record_limit(1000).batch(2500).reject{ |u| u['user_name'] == '_prize' }.each do |point|
      #   user_name = point['user_name'] || 'Not Claimed'
      #   user_id = point['user_id'] || 'Not Claimed'
        
      #   if result[user_id].nil?
      #     result[user_id] = {}
      #     result[user_id]['user_name'] = user_name
      #     result[user_id]['points'] = 0
      #     result[user_id]['poke_value'] = 0
      #   end

      #   if result[user_id]['best_pokemon'].nil? or point['value'].to_f > result[user_id]['best_pokemon']['value'].to_f
      #     result[user_id]['best_pokemon'] = point
      #   end
        
      #   result[user_id]['points'] += 1
      #   result[user_id]['poke_value'] += point['value'].to_f
      #   result[user_id]['poke_value'] = result[user_id]['poke_value'].round(2)
      # end
      # Rails.cache.dalli.with do |client|
      #   client.set('leaderboardCachedResponse', result)
      # end
      result
    end
    
    # def self.refresh_and_cache_recent
    #   points = {}
    #   points = Point.record_limit(10000).batch(2500).reject{ |u| u['user_name'] == '_prize' }.sort do |a, b|
    #     b.create_date.to_i <=> a.create_date.to_i
    #   end
    #   # Rails.cache.dalli.with do |client|
    #   #   client.set('mostRecentCachedResponse', points)
    #   # end
    #   points
    # end
    
    def leaderboard
      # Rails.cache.dalli.with do |client|
      #   leaderboardCachedResponse = client.get('leaderboardCachedResponse')

      #   if not leaderboardCachedResponse
      #     Api::V1::PointController.refresh_and_cache_leaderboard
      #     leaderboardCachedResponse = client.get('leaderboardCachedResponse')
      #   end
      #   render_and_log_to_db(json: {result: Hash[leaderboardCachedResponse.sort_by {|_key, value| value['poke_value'].to_f}.reverse]}, status: 200)
      # end
      leaderboardCachedResponse = Api::V1::PointController.refresh_and_cache_leaderboard
      render_and_log_to_db(json: {result: Hash[leaderboardCachedResponse.sort_by {|_key, value| value['poke_value'].to_f}.reverse]}, status: 200)
    end
    
    def get_most_recent
      recents = Recent.all.sort_by do |recent|
        recent.created_at
      end
      
      recent_ids = recents.map do |recent|
        recent.id
      end.reverse

      results = Point.find_all(recent_ids.first(5)).sort_by do |recent|
        recent.created_at
      end.reverse.to_a
      
      if recents.length > 10
        recents[0..-6].each do |recent|
          recent.delete
        end
      end

      # mostRecentCachedResponse = Api::V1::PointController.refresh_and_cache_recent
      render_and_log_to_db(json: {result: results}, status: 200)
      # Rails.cache.dalli.with do |client|
      #   mostRecentCachedResponse = client.get('mostRecentCachedResponse')
        
      #   if not mostRecentCachedResponse
      #     Api::V1::PointController.refresh_and_cache_recent
      #     mostRecentCachedResponse = client.get('mostRecentCachedResponse')
      #   end
      #   render_and_log_to_db(json: {result: mostRecentCachedResponse[0..4]}, status: 200)
      # end
    end
    
    def get_user
      # result = {}

      user = User.where(user_name: allowed_params['user_name']).all.first

      # points = user[:points].map do |id, point_ids|
      #   {
      #     :point => Api::V1::PointController.create_point_obj(id),
      #     :count => point_ids.length
      #   }
      # end

      # # Change this to new API response
      # result = points.map do |point|
      #   {
      #     :user_name => user[:user_name],
      #     :user_id => user[:user_id],
      #     :names => user[:names],
      #     :friendly_id => point[:point][:friendly_id],
      #     :friendly_name => point[:point][:friendly_name],
      #     :value => point[:point][:value]
      #   }
      # end
      results = {}
      values = user[:points].map do |id, value|
        results[Api::V1::PointController.get_id_weight(id)] = value
      end


      points_to_query = []
      results.sort.reverse.each do |value, point_ids|
        if points_to_query.length < 100
          points_to_query += point_ids
        else
          break
        end
      end

      points = Point.find_all(points_to_query).sort_by do |point|
        [point[:value], point[:capture_date]]
      end.reverse
      
      if points
        render_and_log_to_db(json: {result: points[0..100]}, status: 200)
      else
        render_and_log_to_db(json: {error: 'Nothing found.'}, status: 400)
      end
    end
    
    def get_pokemon
      users = User.all.reject{ |u| u['user_name'] == '_prize' }
      list_of_point_ids = users.map do |user|
        user[:points][params['friendly_id'].to_i] || []
      end.flatten

      points = Point.find_all(list_of_point_ids).sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end

      # points = Point.record_limit(50000).batch(2500).where(friendly_id: params['friendly_id']).all
      #               .reject{ |u| u['user_name'] == '_prize' }.sort do |a, b|
      #                 b.create_date.to_i <=> a.create_date.to_i
      #               end
                    
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
        # CacheLeaderboard.perform_async
        # CacheRecent.perform_async
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
        if !@@point_update_mutex[allowed_params['point_id']]
          @@point_update_mutex[allowed_params['point_id']] = Mutex.new
        end
        @@point_update_mutex[allowed_params['point_id']].synchronize do
          point = Point.find_by_id(allowed_params['point_id'])
          if !point
            render_and_log_to_db(json: {error: 'Invalid point id. Nice try...'}, status: 400)
          elsif point.user.nil?
            user = User.find_by_id(allowed_params['user']['id'])
            if !user
              user = User.create(
                user_id: allowed_params['user']['id'],
                user_name: allowed_params['user']['name'] || allowed_params['user']['id'],
                points: {},
                names: []
              )
            end
            
            point.user = {
              :name => user[:user_name],
              :id => user[:user_id]
            }
            point.user_name = user[:user_name]
            point.user_id = user[:user_id]
            point.capture_date = DateTime.now
            point.save
            Pusher.trigger('point', 'point_updated', {
              result: point
            })

            friendly_id = point[:friendly_id].to_i
            if !user[:points][friendly_id]
              user[:points][friendly_id] = []
            end

            user[:points][friendly_id] = user[:points][friendly_id].append(point[:id])
            user[:names] = user[:names].append(allowed_params['user']['name']).compact
            user.save

            # CacheLeaderboard.perform_async
            # CacheRecent.perform_async
            render_and_log_to_db(json: {result: point}, status: 200)
          else
            render_and_log_to_db(json: {error: "This #{point['friendly_name']} has already been captured by #{point[:user_name]}."}, status: 400)
          end
        end
        @@point_update_mutex.delete(allowed_params['point_id'])
      else
        render_and_log_to_db(json: {error: "Please enter a valid secret."}, status: 400)
      end
    end
    
    def self.get_id_weight(id)
      if id > 251
        ((id - 251) * 151.0/135).round(2)
      elsif id > 151
        (id - 151) * 151.0/100
      else
        id
      end
    end

    def self.calculate_points(points)
      point = 0
      points.each do |id, number|
        point += (number.length * get_id_weight(id))
      end

      point.round(2)
    end

    def self.get_best_pokemon(points)
      results = {}
      values = points.map do |id, value|
        results[self.get_id_weight(id)] = id
      end
      results.sort.last.last
    end

    def self.create_point_obj(id)
      {
        :friendly_id => id,
        :value => self.get_id_weight(id),
        :friendly_name => Pokemon.pokemon_info[id - 1][:name].capitalize
      }
    end

    def self.create_points
      c = 2*Random.rand(151.0*(151+1)/2)
      n = ((1 + Math.sqrt(1**2 + 4*c))/2)
      
      if Random.rand > 0.66
        n = (((152 - n) * 135/151).ceil + 251).to_int
      elsif Random.rand > 0.33
        n = (((152 - n) * 100/151).ceil + 151).to_int
      else
        n = 152 - n.to_int
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
      
      Recent.create(
        :id => point.id,
      )
      
      # CacheLeaderboard.perform_async
      # CacheRecent.perform_async
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

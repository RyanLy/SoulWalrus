module Api::V1
  class PointController < ApiController
    @@point_update_mutex = {}

    def index
      result = {}

      User.all.reject { |u| u['user_id'] == '-1' }.each do |user|
        user_name = user[:user_name] || 'Not Claimed'
        user_id = user[:user_id] || 'Not Claimed'
        result[user_id] = {
          'user_name' => user_name,
          'points' => user[:points].values.inject(0) { |sum, val| sum + val.length }
        }
      end
      render_and_log_to_db(json: { result: Hash[result.sort_by { |_key, value| value['points'].to_int }.reverse] }, status: 200)
    end

    def self.refresh_and_cache_leaderboard
      result = {}

      User.all.reject { |u| u['user_id'] == '-1' }.each do |user|
        user_name = user[:user_name] || 'Not Claimed'
        user_id = user[:user_id] || 'Not Claimed'

        best_pokmemon_id = get_best_pokemon(user[:points])
        best_pokemon = create_point_obj(best_pokmemon_id)

        result[user_id] = {
          'user_name' => user_name,
          'points' => user[:points].values.inject(0) { |sum, val| sum + val.length },
          'poke_value' => calculate_points(user[:points]),
          'best_pokemon' => best_pokemon
        }
      end
      result
    end


    def leaderboard
      leaderboardCachedResponse = Api::V1::PointController.refresh_and_cache_leaderboard
      render_and_log_to_db(json: { result: Hash[leaderboardCachedResponse.sort_by { |_key, value| value['poke_value'].to_f }.reverse] }, status: 200)
    end

    def get_most_recent
      recents = Recent.all.sort_by(&:created_at)

      recent_ids = recents.map(&:id).reverse

      results = Point.find_all(recent_ids.first(5)).sort_by(&:created_at).reverse.to_a

      recents[0..-6].each(&:delete) if recents.length > 10

      render_and_log_to_db(json: { result: results }, status: 200)
    end

    def get_user
      user = User.where(user_name: allowed_params['user_name']).all.first

      results = {}
      values = user[:points].map do |id, value|
        results[Api::V1::PointController.get_id_weight(id)] = value
      end

      points_to_query = []
      results.sort.reverse.each do |_value, point_ids|
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
        render_and_log_to_db(json: { result: points[0..100] }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Nothing found.' }, status: 400)
      end
    end

    def get_pokemon
      users = User.all.reject { |u| u['user_name'] == '_prize' }
      list_of_point_ids = users.map do |user|
        user[:points][params['friendly_id'].to_i] || []
      end.flatten

      points = Point.find_all(list_of_point_ids).sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end

      if points
        render_and_log_to_db(json: { result: points }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Nothing found.' }, status: 400)
      end
    end

    def create
      render_and_log_to_db(json: { error: 'Non-existent secret' }, status: 400) unless allowed_params['point_secret']

      if allowed_params['point_secret'] == ENV['POINT_SECRET']
        point = Point.new(
          user: nil,
          user_name: nil,
          user_id: nil,
          description: 'Points v1',
          create_date: DateTime.now
        )
        point.save
        render_and_log_to_db(json: { result: point }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Please enter a valid secret.' }, status: 400)
      end
    end

    def update
      render_and_log_to_db(json: { error: 'Please specify a chatid' }, status: 400) unless allowed_params['user']
      render_and_log_to_db(json: { error: 'Non-existent secret' }, status: 400) unless allowed_params['point_secret']
      render_and_log_to_db(json: { error: 'Please specify an point_id' }, status: 400) unless allowed_params['point_id']

      if allowed_params['point_secret'] == ENV['POINT_SECRET']
        unless @@point_update_mutex[allowed_params['point_id']]
          @@point_update_mutex[allowed_params['point_id']] = Mutex.new
        end
        @@point_update_mutex[allowed_params['point_id']].synchronize do
          point = Point.find_by_id(allowed_params['point_id'])
          if !point
            render_and_log_to_db(json: { error: 'Invalid point id. Nice try...' }, status: 400)
          elsif point.user.nil?
            user = User.find_by_id(allowed_params['user']['id'])
            user ||= User.create(
              user_id: allowed_params['user']['id'],
              user_name: allowed_params['user']['name'] || allowed_params['user']['id'],
              points: {},
              names: []
            )

            point.user = {
              name: user[:user_name],
              id: user[:user_id]
            }
            point.user_name = user[:user_name]
            point.user_id = user[:user_id]
            point.capture_date = DateTime.now
            point.save
            Pusher.trigger('point', 'point_updated',
                           result: point)

            friendly_id = point[:friendly_id].to_i
            user[:points][friendly_id] = [] unless user[:points][friendly_id]

            user[:points][friendly_id] = user[:points][friendly_id].append(point[:id])
            user[:names] = user[:names].append(allowed_params['user']['name']).compact.uniq
            user.save

            render_and_log_to_db(json: { result: point }, status: 200)
          else
            render_and_log_to_db(json: { error: "This #{point['friendly_name']} has already been captured by #{point[:user_name]}." }, status: 400)
          end
        end
        @@point_update_mutex.delete(allowed_params['point_id'])
      else
        render_and_log_to_db(json: { error: 'Please enter a valid secret.' }, status: 400)
      end
    end

    def self.get_id_weight(id)
      if id > 251
        ((id - 251) * 151.0 / 135).round(2)
      elsif id > 151
        (id - 151) * 151.0 / 100
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
      values = points.map do |id, _value|
        results[get_id_weight(id)] = id
      end
      results.max.last
    end

    def self.create_point_obj(id)
      {
        friendly_id: id,
        value: get_id_weight(id),
        friendly_name: Pokemon.pokemon_info[id - 1][:name].capitalize
      }
    end

    def self.create_points
      c = 2 * Random.rand(151.0 * (151 + 1) / 2)
      n = ((1 + Math.sqrt(1**2 + 4 * c)) / 2)

      n = if Random.rand > 0.66
            (((152 - n) * 135 / 151).ceil + 251).to_int
          elsif Random.rand > 0.33
            (((152 - n) * 100 / 151).ceil + 151).to_int
          else
            152 - n.to_int
          end

      point = Point.create(
        user: nil,
        user_name: nil,
        user_id: nil,
        description: 'Points v1',
        create_date: DateTime.now,
        friendly_id: n,
        value: get_id_weight(n),
        friendly_name: Pokemon.pokemon_info[n - 1][:name].capitalize
      )
      Pusher.trigger('point', 'point_created',
                     result: point)

      Recent.create(
        id: point.id
      )
    end

    private

    def allowed_params
      params.permit([
                      [user: %i[id name]],
                      :point_secret,
                      :point_id,
                      :user_id,
                      :user_name
                    ])
    end
  end
end

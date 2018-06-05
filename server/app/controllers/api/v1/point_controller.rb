module Api::V1
  class PointController < ApiController
    @@point_update_mutex = {}

    def index
      users = {}
      User.all.reject { |u| u[:user_id] == '-1' }.each do |user|
        users[user[:user_id]] = {
          user_name: user[:user_name],
          points: 0
        }
      end

      users.keys.each do |user_id|
        UserPoint.where(user_id: user_id).each do |user_point|
          users[user_id][:points] = users[user_id][:points] + user_point[:points].length
        end
      end
      render_and_log_to_db(json: { result: Hash[users.sort_by { |_key, value| value[:points].to_int }.reverse] }, status: 200)
    end

    def leaderboard
      users = {}
      User.all.reject { |u| u[:user_id] == '-1' }.each do |user|
        users[user[:user_id]] = {
          user_name: user[:user_name],
          points: {}
        }
      end

      users.keys.each do |user_id|
        UserPoint.where(user_id: user_id).each do |user_point|
          users[user_id][:points][user_point[:friendly_id]] = user_point[:points]
        end
      end

      result = {}
      users.each do |user_id, user|
        unless user[:points].empty?
          best_pokmemon_id = Point.get_best_point(user[:points])
          best_pokemon = Api::V1::PointController.create_point_obj(best_pokmemon_id)
        end
        result[user_id] = {
          user_name: user[:user_name],
          points: user[:points].values.inject(0) { |sum, val| sum + val.length },
          poke_value: Point.calculate_points(user[:points]),
          best_pokemon: best_pokemon
        }
      end
      render_and_log_to_db(json: { result: Hash[result.sort_by { |_key, value| value[:poke_value].to_f }.reverse] }, status: 200)
    end

    def get_most_recent
      recents = Recent.all.sort_by(&:created_at)
      recent_ids = recents.map(&:id).reverse

      results = Point.find_all(recent_ids.first(5)).sort_by(&:created_at).reverse.to_a
      recents[0..-6].each(&:delete) if recents.length > 10

      render_and_log_to_db(json: { result: results }, status: 200)
    end

    def get_user
      user_model = User.where(user_name: allowed_params[:user_name]).first
      p user_model
      user_points = UserPoint.where(user_id: user_model[:user_id])

      results = {}
      user_points.each do |user_point|
        results[Point.get_id_weight(user_point[:friendly_id].to_i)] = user_point[:points]
      end

      points_to_query = []
      results.sort.reverse.each do |_value, point_ids|
        break if points_to_query.length > 99
        points_to_query += point_ids
      end

      points = Point.find_all(points_to_query).sort_by do |point|
        [Point.get_id_weight(point[:friendly_id].to_i), point[:capture_date]]
      end.reverse

      if points
        render_and_log_to_db(json: { result: points[0..100] }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Nothing found.' }, status: 400)
      end
    end

    def get_pokemon
      # friendly_id is a string in the Points table
      points = Point.where(friendly_id: params[:friendly_id].to_i).reject { |u| u[:user_id] == '-1' }.sort do |a, b|
        b.create_date.to_i <=> a.create_date.to_i
      end

      if points
        render_and_log_to_db(json: { result: points }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Nothing found.' }, status: 400)
      end
    end

    def create
      render_and_log_to_db(json: { error: 'Non-existent secret' }, status: 400) unless allowed_params[:point_secret]

      if allowed_params[:point_secret] == ENV['POINT_SECRET']
        point = Point.new(
          user_id: nil,
          description: 'Points v1.1',
          create_date: DateTime.now
        )
        point.save
        render_and_log_to_db(json: { result: point }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Please enter a valid secret.' }, status: 400)
      end
    end

    def update
      point_id = allowed_params[:point_id]
      user_id = allowed_params[:user][:id]
      user_name_param = allowed_params[:user][:name]

      render_and_log_to_db(json: { error: 'Please specify a chatid' }, status: 400) unless allowed_params[:user]
      render_and_log_to_db(json: { error: 'Non-existent secret' }, status: 400) unless allowed_params[:point_secret]
      render_and_log_to_db(json: { error: 'Please specify an point_id' }, status: 400) unless allowed_params[:point_id]

      if allowed_params[:point_secret] == ENV['POINT_SECRET']
        unless @@point_update_mutex[point_id]
          @@point_update_mutex[point_id] = Mutex.new
        end
        @@point_update_mutex[point_id].synchronize do
          point = Point.find_by_id(point_id)
          if !point
            render_and_log_to_db(json: { error: 'Invalid point id. Nice try...' }, status: 400)
          elsif point[:user_id].nil?
            user = User.find_by_id(user_id)
            unless user
              user_name = user_name_param || user_id
              user ||= User.create(
                user_id: user_id,
                user_name: user_name,
                names: [user_name]
              )
            end
            user[:names] = user[:names].append(user_name_param).compact.uniq
            user.save

            friendly_id = point[:friendly_id].to_i
            user_point = UserPoint.find_by_composite_key(user[:user_id], friendly_id)
            unless user_point
              user_point ||= UserPoint.create(
                user_id: user[:user_id],
                friendly_id: friendly_id,
                points: []
              )
            end

            user_point[:points] = (user_point[:points] || []).append(point[:id])
            point.user_id = user[:user_id]
            # TODO: Remove user_name in point model
            point.user_name = user[:user_name]
            point.capture_date = DateTime.now

            point.save
            user_point.save

            point.user = {
              name: user[:user_name],
              id: user[:user_id]
            }

            Pusher.trigger('point', 'point_updated',  result: point)
            render_and_log_to_db(json: { result: point }, status: 200)
          else
            user = User.find_by_id(point[:user_id])
            render_and_log_to_db(json: { error: "This #{point[:friendly_name]} has already been captured by #{user[:user_name]}." }, status: 400)
          end
        end
        @@point_update_mutex.delete(allowed_params[:point_id])
      else
        render_and_log_to_db(json: { error: 'Please enter a valid secret.' }, status: 400)
      end
    end

    def self.create_point_obj(id)
      {
        friendly_id: id,
        value: Point.get_id_weight(id),
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
        description: 'Points v1.1',
        create_date: DateTime.now,
        friendly_id: n,
        value: Point.get_id_weight(n),
        friendly_name: Pokemon.pokemon_info[n - 1][:name].capitalize
      )
      Pusher.trigger('point', 'point_created', result: point)
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

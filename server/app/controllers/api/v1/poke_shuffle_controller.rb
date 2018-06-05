module Api::V1
  class PokeShuffleController < ApiController
    def index
      result = PokeShuffle.all.map do |entry|
        point = Point.find_by_id(entry.point_id)
        {
          user_name: point[:user_id] == '-1' ? 'Prize' : point[:user_name],
          friendly_name: point[:friendly_name],
          friendly_id: point[:friendly_id],
          value: point[:value]
        }
      end
      render_and_log_to_db(json: { result: result }, status: 200)
    end

    def create
      if allowed_params[:point_secret] == ENV['POINT_SECRET']
        if !allowed_params[:friendly_name].nil?
          allowed_user_id = allowed_params[:user][:id]
          allowed_friendly_name = allowed_params[:friendly_name] || ''
          allowed_friendly_name_int = allowed_friendly_name.to_i

          # If the friendly name is a number
          friendly_id = if allowed_friendly_name_int.to_s == allowed_friendly_name
                          allowed_friendly_name_int
                        else
                          Pokemon.name_to_number_info(allowed_friendly_name)
                        end

          unless friendly_id
            render_and_log_to_db(json: { error: 'Please choose a valid pokemon to enter with.' }, status: 400)
            return
          end

          user_point = UserPoint.find_by_composite_key(allowed_user_id, friendly_id)
          if user_point
            point_id = user_point[:points].last
            point = Point.find_by_id(point_id) if point_id
          end

          if point
            # Figure out if user is already entered
            entered = PokeShuffle.where(user_id: allowed_user_id).all.first
            user = User.find_by_id(allowed_user_id)

            if entered
              entered_pokemon = Point.find_by_id(entered.point_id)
              entered.point_id = point.id
              entered.save
              render_and_log_to_db(json: { result: "#{user.user_name}'s #{point.friendly_name}(#{point.friendly_id}|#{point.value}) has been entered into the tournament. "\
                                                  "This entry replaces #{entered_pokemon.friendly_name}(#{entered_pokemon.friendly_id}|#{entered_pokemon.value})." }, status: 200)
            else
              PokeShuffle.create(
                user_id: allowed_user_id,
                point_id: point.id
              )
              render_and_log_to_db(json: { result: "#{user.user_name}'s #{point.friendly_name}(#{point.friendly_id}|#{point.value}) has been entered into the tournament." }, status: 200)
            end
          else
            available_points = ([friendly_id - 4, 0].max..[friendly_id + 4, Pokemon.pokemon_info.length].min).select do |friendly_id|
              user_point = UserPoint.find_by_composite_key(allowed_user_id, friendly_id)
              user_point && user_point[:points].length
            end

            # Recommendations
            unique_points = available_points.collect { |point_id| { friendly_name: Pokemon.pokemon_info[point_id - 1][:name].capitalize, friendly_id: point_id } }
                                            .sort_by { |point| point[:friendly_id].to_i }
                                            .map { |point| "#{point[:friendly_name]}(#{point[:friendly_id]})" }
                                            .join(', ')
            render_and_log_to_db(json: { error: "Please choose a valid pokemon to enter with. <br/><b>Suggestions:</b> #{unique_points}" }, status: 400)
          end
        else
          render_and_log_to_db(json: { error: 'Please choose a valid pokemon to enter with.' }, status: 400)
        end
      else
        render_and_log_to_db(json: { error: 'Please enter a valid secret.' }, status: 400)
      end
    end

    def delete
      if allowed_params[:point_secret] == ENV['POINT_SECRET']
        entered = PokeShuffle.where(user_id: allowed_params[:user]['id']).all.first

        if entered
          entered_pokemon = Point.find_by_id(entered.point_id)
          entered.delete
          render_and_log_to_db(json: { result: "#{entered_pokemon.user_name}'s #{entered_pokemon.friendly_name}(#{entered_pokemon.friendly_id}|#{entered_pokemon.value}) has been removed from the tournament." }, status: 200)
        else
          render_and_log_to_db(json: { result: 'No Pokemon was entered.' }, status: 200)
        end
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

    def self.create_point_and_shuffle
      c = 22_952
      (0..10).each do |_|
        c = [c, 2 * Random.rand(151 * (151 + 1) / 2)].min
      end
      n = ((1 + Math.sqrt(1**2 + 4 * c)) / 2)

      n = if Random.rand > 0.66
            (((152 - n) * 135 / 151).ceil + 251).to_int
          elsif Random.rand > 0.33
            (((152 - n) * 100 / 151).ceil + 151).to_int
          else
            152 - n.to_int
          end

      point = Point.create(
        user: { name: '_prize', id: '-1' },
        user_name: '_prize',
        user_id:  '-1',
        friendly_id: n,
        value: get_id_weight(n),
        friendly_name: Pokemon.pokemon_info[n - 1][:name].capitalize
      )

      PokeShuffle.create(
        user_id: '-1',
        point_id: point.id
      )

      point
    end

    def create_prize
      if allowed_params[:point_secret] == ENV['POINT_SECRET']

        if PokeShuffle.where(user_id: '-1').first
          render_and_log_to_db(json: { error: 'A prize is already created.' }, status: 400)
        else
          point = create_point_and_shuffle
          render_and_log_to_db(json: { error: point }, status: 400)
        end
      else
        render_and_log_to_db(json: { error: 'Please enter a valid secret.' }, status: 400)
      end
    end

    def self.end_tourney
      p 'End Tourney'
      entries = PokeShuffle.all.map do |entry|
        Point.find_by_id(entry.point_id)
      end.compact

      player_entries = entries.reject { |point| point.user_id == '-1' }

      if !player_entries.empty?
        sum_ids = player_entries.reduce(0) { |sum, obj| sum + obj.value.to_f }
        random = Random.rand(sum_ids)
        total = 0
        winner = nil

        p "Sum IDs: #{sum_ids}"
        p "Random: #{random}"
        player_entries.each do |entry|
          current_id = entry.value.to_f
          if random >= total && random < (total + current_id)
            winner = entry
            break
          end
          total += current_id
        end

        poke_names = entries.map { |entry| "#{User.find_by_id(entry.user_id)[:user_name]}'s #{entry.friendly_name}(#{entry.friendly_id}|#{entry.value})" }
        sum_all_ids = entries.reduce(0) { |sum, obj| sum + obj.value.to_f }

        winner_user = User.find_by_id(winner.user_id)
        entries.each do |entry|
          entry_friendly_id = entry[:friendly_id].to_i

          # Could be the _prize
          loser = UserPoint.where(user_id: entry.user_id, friendly_id: entry_friendly_id).first
          if loser
            loser[:points] = (loser[:points] || []).reject do |point_id|
              point_id == entry[:id]
            end
            loser.save
          end

          winner_user_point = UserPoint.find_by_composite_key(winner.user_id, entry_friendly_id)
          if winner_user_point
            winner_user_point[:points] = (winner_user_point[:points] || []).append(entry[:id]).uniq
            winner_user_point.save
          else
            UserPoint.create(
              user_id: winner_user[:user_id],
              friendly_id: entry_friendly_id,
              points: [entry[:id]],
            )
          end

          # Write the new owner of the entries
          entry.user_id = winner_user[:user_id]
          entry.user_name = winner_user[:user_name]
          entry.create_date = DateTime.now if entry.create_date.nil?
          entry.capture_date = DateTime.now
          entry.save
        end

        PokeShuffle.all.each(&:delete)

        p "Tourney ends!\n#{winner_user.user_name} Wins (+#{sum_all_ids})! #{winner_user.user_id} has obtained #{poke_names.join(', ')}"
        Pusher.trigger('poke_shuffle', 'tourney_end',
                       result: "Tourney ends!\n#{winner_user.user_name} Wins (+#{sum_all_ids.round(2)})! #{User.find_by_id(winner_user.user_id)[:user_name]} has obtained #{poke_names.join(', ')}")
      else
        p 'Tourney ends! There is no winner.'
        PokeShuffle.all.each(&:delete)

        Pusher.trigger('poke_shuffle', 'tourney_end',
                       result: 'Tourney ends! There is no winner.')
      end
    end

    def self.start_tourney
      p 'Start Tourney'
      if PokeShuffle.where(user_id: '-1').all.first
        p 'A tourney is already started..'
      else
        point = create_point_and_shuffle

        p "Tourney starts! The prize for this tourney is #{point.friendly_name}(#{point.friendly_id}|#{point.value}). It ends in 8 hours."
        Pusher.trigger('poke_shuffle', 'tourney_start',
                       result: point)
      end
    end

    private

    def allowed_params
      params.permit([
                      [user: %i[id name]],
                      :point_secret,
                      :friendly_name,
                      :user_id,
                      :user_name
                    ])
    end
  end
end

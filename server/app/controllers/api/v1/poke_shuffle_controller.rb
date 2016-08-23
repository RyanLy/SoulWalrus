module Api::V1
  class PokeShuffleController < ApiController
    
    def index
      result = PokeShuffle.all.map do |entry|
        point = Point.find_by_id(entry.point_id)
        {
          user_name: point.user_name == '_prize' ? 'Prize' : point.user_name,
          friendly_name: point.friendly_name
        }
      end
      render_and_log_to_db(json: {result: result}, status: 200)
    end
    
    def create
      if allowed_params[:point_secret] == ENV['POINT_SECRET']
        point = Point.where(user_id: allowed_params[:user]['id'], friendly_name: allowed_params[:friendly_name].capitalize)
                      .all.first
        if point.nil?
          point = Point.where(user_id: allowed_params[:user]['id'], friendly_id: allowed_params[:friendly_name].capitalize)
                        .all.first
        end
        
        if point
          entered = PokeShuffle.where(user_id: allowed_params[:user]['id']).all.first
        
          if entered
            entered_pokemon = Point.find_by_id(entered.point_id)
            entered.point_id = point.id
            entered.save
            render_and_log_to_db(json: {result: "#{point.user_name}'s #{point.friendly_name} has been entered into the tournament. "\
                                                "This entry replaces #{entered_pokemon.friendly_name}."}, status: 200)
          else
            PokeShuffle.create(
              user_id: allowed_params[:user]['id'],
              point_id: point.id
            )
            render_and_log_to_db(json: {result: "#{point.user_name}'s #{point.friendly_name} has been entered into the tournament."}, status: 200)
          end
        else
          render_and_log_to_db(json: {error: 'Please choose a valid pokemon to enter with.'}, status: 400)
        end
      else
        render_and_log_to_db(json: {error: 'Please enter a valid secret.'}, status: 400)
      end
    end
    
    def delete
      if allowed_params[:point_secret] == ENV['POINT_SECRET']
        entered = PokeShuffle.where(user_id: allowed_params[:user]['id']).all.first
      
        if entered
          entered_pokemon = Point.find_by_id(entered.point_id)
          entered.delete
          render_and_log_to_db(json: {result: "#{entered_pokemon.user_name}'s #{entered_pokemon.friendly_name} has been removed from the tournament."}, status: 200)
        else
          render_and_log_to_db(json: {result: "No Pokemon was entered."}, status: 200)
        end
      else
        render_and_log_to_db(json: {error: 'Please enter a valid secret.'}, status: 400)
      end
    end
    
    def create_prize
      if allowed_params[:point_secret] == ENV['POINT_SECRET']
      
        if PokeShuffle.where(user_id: '_prize').all.first
          render_and_log_to_db(json: {error: "A prize is already created."}, status: 400)
        else
          c = 2*Random.rand(151*(151+1)/2)
          n = 152 - ((1 + Math.sqrt(1**2 + 4*c))/2).to_int
          
          point = Point.create(
            user: {name: '_prize', id: '-1'},
            user_name: '_prize',
            user_id:  '-1',
            friendly_id: n,
            friendly_name: Pokemon.pokemon_info[n-1][:name].capitalize
          )
          
          PokeShuffle.create(
            user_id: '_prize',
            point_id: point.id
          )
          render_and_log_to_db(json: {error: point}, status: 400)
        end
      else
        render_and_log_to_db(json: {error: 'Please enter a valid secret.'}, status: 400)
      end
    end
    
    def self.end_tourney
      p "End Tourney"
      entries = PokeShuffle.all.map do |entry|
        Point.find_by_id(entry.point_id)
      end
      player_entries = entries.reject { |point| point.user_name == '_prize' }
      
      if player_entries.length > 0
        sum_ids = player_entries.reduce(0) { |sum, obj| sum + obj.friendly_id.to_i }
        random = Random.rand(sum_ids)
        total = 0
        winner = nil
        
        p "Sum IDs: #{sum_ids}"
        p "Random: #{random}"
        player_entries.each do |entry|
          current_id = entry.friendly_id.to_i
          if random >= total && random < (total + current_id)
            winner = entry
            break
          end
          total += current_id
        end
      
        poke_names = entries.map { |entry| entry.friendly_name }
        poke_losers = entries.map { |entry| entry.user_name }
      
        entries.each do |entry|
          entry.user = winner.user
          entry.user_name = winner.user_name
          entry.user_id = winner.user_id
          entry.create_date = DateTime.now
          entry.capture_date = DateTime.now
          entry.save
        end
        PokeShuffle.all.each(&:delete)
        
        p "Tourney ends!\n#{winner.user_name} Wins! #{winner.user_name} has obtained #{poke_names.join(', ')} from #{poke_losers.join(', ')}"
        Pusher.trigger('poke_shuffle', 'tourney_end', {
          result: "Tourney ends!\n#{winner.user_name} Wins! #{winner.user_name} has obtained #{poke_names.join(', ')} from #{poke_losers.join(', ')}"
        })
      else
        p 'Tourney ends! There is no winner.'
        PokeShuffle.all.each(&:delete)
        
        Pusher.trigger('poke_shuffle', 'tourney_end', {
          result: 'Tourney ends! There is no winner.'
        })
      end
    end
    
    def self.start_tourney
      p "Start Tourney"
      if PokeShuffle.where(user_id: '_prize').all.first
        p "A tourney is already started.."
      else
        c = 2*Random.rand(151*(151+1)/2)
        n = 152 - ((1 + Math.sqrt(1**2 + 4*c))/2).to_int
        
        point = Point.create(
          user: {name: '_prize', id: '-1'},
          user_name: '_prize',
          user_id:  '-1',
          friendly_id: n,
          friendly_name: Pokemon.pokemon_info[n-1][:name].capitalize
        )
        
        PokeShuffle.create(
          user_id: '_prize',
          point_id: point.id
        )
        
        p "Tourney starts! The prize for this tourney is #{point.friendly_name}. It ends in 8 hours."
        Pusher.trigger('poke_shuffle', 'tourney_start', {
          result: point
        })
      end
    end
    
    private
    def allowed_params
      params.permit([
        [user: [:id, :name]],
        :point_secret,
        :friendly_name,
        :user_id,
        :user_name
      ])
    end
  end
end

require 'unirest'

module Api::V1
  class CsgoController < ApiController

    def bot_train_t
      render_and_log_to_db(json: 
      {result: 
        [
          'changelevel de_dust2;',
          'mp_autoteambalance 0;',
          'mp_limitteams 0;',
          'mp_maxrounds 100;',
          'bot_kick;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_add_t;',
          'bot_difficulty 3;'
        ] 
      }, status: 200)
     end
     
     def bot_train_ct
       render_and_log_to_db(json: 
       {result: 
         [
           'changelevel de_dust2;',
           'mp_autoteambalance 0;',
           'mp_limitteams 0;',
           'mp_maxrounds 100;',
           'bot_kick;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_add_ct;',
           'bot_difficulty 3;'
         ] 
       }, status: 200)
      end

    def self.create_lobby_link(player_object)
      return "steam://joinlobby/%s/%s/%s" % [ player_object['gameid'], player_object['lobbysteamid'], player_object['steamid'] ]
    end

    def join_game
      if params['id']
        response = Unirest.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s' % [ ENV['STEAM_KEY'], params['id'] ]
        if response.body['response']['players'][0]['lobbysteamid']
          redirect_to Api::V1::CsgoController.create_lobby_link(response.body['response']['players'][0])
        else
          render_and_log_to_db(json: { error: "Lobby not found" }, status: 400)
        end
      else
        render_and_log_to_db(json: { error: "Please specify an id" }, status: 400)
      end
    end
    
    def self.pollLobby
      result = CsgoLobby.all
      for lobby in result
        response = Unirest.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s' % [ ENV['STEAM_KEY'], lobby.id ]
        lobbyid = response.body['response'] && response.body['response']['players'] && response.body['response']['players'][0] && response.body['response']['players'][0]['lobbysteamid']
        if lobbyid and lobby.lobbyid != lobbyid
          Pusher.trigger('csgo', 'open_lobby', {
            result: response.body['response']['players'][0]
          })
          lobby.lobbyid = lobbyid
          lobby.save
        end
      end
    end
  end
end

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
          'bot_difficulty'
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
           'bot_difficulty'
         ] 
       }, status: 200)
      end

    def self.create_lobby_link(player_object)
      return "steam://joinlobby/730/%s/76561197990897837" % [ player_object['lobbysteamid'] ]
    end

    def join_game
      response = Unirest.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=76561197990897837' % [ ENV['STEAM_KEY'] ]
      if response.body['response']['players'][0]['lobbysteamid']
        redirect_to Api::V1::CsgoController.create_lobby_link(response.body['response']['players'][0])
      else
        render_and_log_to_db(json: { error: "Lobby not found" }, status: 400)
      end
    end
    
    def self.pollLobby
      result = CsgoLobby.all
      for lobby in result
        response = Unirest.get 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=76561197990897837' % [ ENV['STEAM_KEY'] ]
        lobbyid = response.body['response']['players'][0]['lobbysteamid']
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

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
  end
end

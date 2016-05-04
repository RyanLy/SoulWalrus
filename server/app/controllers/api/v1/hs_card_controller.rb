require 'unirest'

module Api::V1
  class HsCardController < ApiController
    
    @@HEARTHSTONE_API_ENDPOINT = 'https://omgvamp-hearthstone-v1.p.mashape.com/cards/search/'
    
    def index
      if params['name']
        response = Unirest.get @@HEARTHSTONE_API_ENDPOINT + params['name'] + "?collectible=1",
                               headers:{
                                 "X-Mashape-Key" => ENV["MASHAPE_KEY"]
                               },
                               parameters:{ :collectible => 1 }

        chosen = nil
        chosen_length = 999
        if response.code == 200 and not response.body.empty?
          for card in response.body
            difference = (card['name'].length - params['name'].length).abs
            if difference < chosen_length
              chosen = card
              chosen_length = difference
            end
          end
          render_and_log_to_db(json: {result: chosen}, status: 200)
        else
          render_and_log_to_db(json: {error: "No card named '%s' found." % [params['name']]}, status: 400)
        end
      else
        render_and_log_to_db(json: {error: "Please enter a card name." }, status: 400)
      end
     end
  end
end

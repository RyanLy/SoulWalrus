require 'http'
require 'json'

module Api::V1
  class StreamerController < ApiController
    
    @@TWITCH_STREAM_ENDPOINT = 'https://api.twitch.tv/kraken/streams/'
    @@TWITCH_USERS_ENDPOINT = 'https://api.twitch.tv/kraken/users/'

    def index
      result = Streamer.all.collect { |x| x['display_name'] }.sort
      render_and_log_to_db(json: { result: result }, status: 200)
     end

    def create
      if params['id']
        queryName = params['id'].downcase
      
        if Streamer.where(:name => queryName).all.empty?
          res = HTTP.get(@@TWITCH_USERS_ENDPOINT + queryName)
          result = JSON.parse(res.to_s)

          if result['error']
            render_and_log_to_db(json: {error:  'Channel does not exist: ' + queryName}, status: 400)
          else
            streamer = Streamer.new(
              :_id => result['_id'],
              :_links => result['_links'],
              :display_name => result['display_name'],
              :name => result['name'],
              :stream => @@TWITCH_STREAM_ENDPOINT + result['name'],
              :updated_at => result['updated_at'],
              :submitted_by => params['submitted_by'],
              :online => false
            )
            streamer.save
            Pusher.trigger('streamer', 'streamer_update', {
              result: Streamer.all.collect { |x| x['display_name'] }.sort
            })
            render_and_log_to_db(json: {result:  streamer}, :status => 200)
          end
        else
          render_and_log_to_db(json: {error:  'Channel already on list.'}, status: 400)
        end
      else
        render_and_log_to_db(json: {error: 'Please specify a Twitch channel'}, status: 400)
      end
    end

    def destroy
      queryName = params['id'].downcase
      results = Streamer.where(:name => queryName).all
      if results.empty?
        render_and_log_to_db(json: {error:  'Channel not on the list.'}, status: 400)
      else
        results[0].delete
        Pusher.trigger('streamer', 'streamer_update', {
          result: Streamer.all.collect { |x| x['display_name'] }.sort
        })
        render_and_log_to_db(json: {result:  queryName +  ' deleted from the list.'}, status: 200)
      end
    end
    
    def self.getLiveHelper
      streamers = Streamer.all
      live = []
      threads = []
      # TODO: Limit thread spawning
      for streamer in streamers
        threads.push(
          Thread.new(streamer) do |streamer| 
            res = HTTP.get(streamer['stream'])
            result = JSON.parse(res.to_s)
            if result['stream']
              live.push(result)
              if streamer['online'] == 'false'
                streamer['online'] = true
                streamer.save
                Pusher.trigger('streamer', 'streamer_online', {
                  result: streamer
                })
              end
            else
              if streamer['online'] == 'true'
                streamer['online'] = false
                streamer.save
                Pusher.trigger('streamer', 'streamer_offline', {
                  result: streamer
                })
              end
            end
          end
        )
      end
      threads.each { |t| t.join }
      return live
    end
    
    def getLive
      live = Api::V1::StreamerController.getLiveHelper
      render_and_log_to_db(json: {result: live}, status: 200)
    end
  end
end

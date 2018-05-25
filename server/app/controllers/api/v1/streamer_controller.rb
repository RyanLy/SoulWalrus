require 'http'
require 'json'

module Api::V1
  class StreamerController < ApiController
    
    @@TWITCH_STREAM_ENDPOINT = 'https://api.twitch.tv/kraken/streams/'
    @@TWITCH_USERS_ENDPOINT = 'https://api.twitch.tv/kraken/users/'
    #@@TWILIO_CLIENT = Twilio::REST::Client.new

    def index
      result = Streamer.all.collect { |x| x['display_name'] }.sort
      render_and_log_to_db(json: { result: result }, status: 200)
     end

    def create
      if params['id']
        queryName = params['id'].downcase
      
        if Streamer.where(:name => queryName).all.to_a.empty?
          res = HTTP.headers("Client-ID": ENV['TWITCH_CLIENT_ID'])
                    .get(@@TWITCH_USERS_ENDPOINT + queryName)
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
            Pusher.trigger('streamer', 'streamer_added', {
              result_added: streamer,
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
      results = Streamer.where(:name => queryName).all.to_a
      if results.empty?
        render_and_log_to_db(json: {error:  'Channel not on the list.'}, status: 400)
      else
        results[0].delete
        Pusher.trigger('streamer', 'streamer_removed', {
          result_removed: results[0],
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
            res = HTTP.headers("Client-ID": ENV['TWITCH_CLIENT_ID'])
                      .get(streamer['stream'])
            result = JSON.parse(res.to_s)
            # Questionable logic. Temporary fix for stream update bugs
            if result['stream']
              live.push(result)
              if streamer['online'] == 'false'
                streamer['online'] = 'true'
                streamer.save
                Pusher.trigger('streamer', 'streamer_online', {
                  result: streamer
                })
                # numbers = @@TWILIO_CLIENT.outgoing_caller_ids.list.collect { |x| x.phone_number }.sort
                # for number in numbers
                #   @@TWILIO_CLIENT.messages.create(
                #     from: '+12048171908',
                #     to: number,
                #     body: '%s is online! - https://www.twitch.tv/%s' % [ streamer['display_name'], streamer['name'] ]
                #   )
                # end
              elsif streamer['online'] == 'uncertain'
                streamer['online'] = 'true'
                streamer.save
              end
            else
              if streamer['online'] == 'uncertain'
                streamer['online'] = 'false'
                streamer.save
                Pusher.trigger('streamer', 'streamer_offline', {
                  result: streamer
                })
              elsif streamer['online'] == 'true'
                streamer['online'] = 'uncertain'
                streamer.save
              end
            end
          end
        )
      end
      threads.each { |t| t.join }
      return live.sort! { |a,b| a['stream']['channel']['display_name'].downcase <=> b['stream']['channel']['display_name'].downcase }
    end
    
    def getLive
      live = Api::V1::StreamerController.getLiveHelper
      render_and_log_to_db(json: {result: live}, status: 200)
    end
  end
end

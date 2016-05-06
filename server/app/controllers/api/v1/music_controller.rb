require 'unirest'
require 'http'

module Api::V1
  class MusicController < ApiController

    def get_recommendation
      # TODO: Store token somewhere and only get a new token if neccessary
      access_token_response = Unirest.post 'https://accounts.spotify.com/api/token',
                                           parameters: {
                                             :grant_type => 'refresh_token',
                                             :refresh_token => ENV['SPOTIFY_REFRESH_TOKEN'],
                                             :client_id =>  ENV['SPOTIFY_CLIENT_ID'],
                                             :client_secret =>  ENV['SPOTIFY_CLIENT_SECRET']
                                           }

      access_token = access_token_response.body['access_token']

      response = Unirest.get 'https://api.spotify.com/v1/recommendations',
                             headers:{ "Authorization" => 'Bearer %s' % [ access_token ] },
                             parameters: { 
                               :seed_tracks => '0c6xIDDpzE81m2q797ordA',
                               :seed_artists => '4NHQUGzhtTLFvgF5SZesLK',
                               :popularity => Random.rand(0..50),
                               :market => 'US',
                               :energy => rand(),
                               :danceability => rand(),
                               :instrumentalness => rand(),
                               :liveness => rand(),
                               :mode => rand(),
                               :speechiness => rand(),
                               :valence => rand(),
                               :limit => 20
                             }
      if response.body['tracks'].length > 0
        new_results = response.body['tracks'].collect { |x| {'id' => x['id'],
                                                             'name' => x['name'],
                                                             'artists' => x['artists'].collect { |y| y['name'] },
                                                             'link' => 'https://play.spotify.com/track/%s' % [ x['id'] ] } } 
        render_and_log_to_db(json: {result: new_results[Random.rand(new_results.length)] }, status: 200)
      else
        render_and_log_to_db(json: {error: "No results" }, status: 400)
      end
    end
  end
end

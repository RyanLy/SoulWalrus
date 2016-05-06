require 'unirest'

module Api::V1
  class MusicController < ApiController

    @@SOUNDCLOUD_GENRES = [
      'Alternative Rock',
      'Ambient',
      'Classical',
      'Country',
      'Dance %26 EDM',
      'Dancehall',
      'Deep House',
      'Disco',
      'Drum %26 Bass',
      'Dubstep',
      'Electronic',
      'Folk %26 Singer-Songwriter',
      'Hip-hop %26 Rap',
      'House',
      'Indie',
      'Jazz %26 Blues',
      #'Latin',
      'Metal',
      'Piano',
      'Pop',
      'R%26B',
      'Reggae',
      'Reggaeton',
      'Rock',
      'Soundtrack',
      'Techno',
      'Trance',
      'Trap',
      'Triphop',
      'World',
      #'Audiobooks',
      #'Business',
      'Comedy',
      'Entertainment',
      #'Learning',
      #'News %26 Politics',
      #'Religion %26 Spirituality',
      #'Science',
      #'Sports',
      #'Storytelling',
      'Technology'
    ]

    def get_recommendation
      if rand() < 0.5
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
                                 :popularity => Random.rand(0..100),
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
          new_results = response.body['tracks']
                        .select { | s | s['is_playable']  }
                        .collect { |x| {'type' => 'SPOTIFY',
                                        'id' => x['id'],
                                        'name' => x['name'],
                                        'artists' => x['artists'].collect { |y| y['name'] },
                                        'link' => 'https://play.spotify.com/track/%s' % [ x['id'] ] } }
          render_and_log_to_db(json: {result: new_results[Random.rand(new_results.length)] }, status: 200)
        else
          render_and_log_to_db(json: {error: "No results" }, status: 400)
        end
      else
        genre = @@SOUNDCLOUD_GENRES[Random.rand(@@SOUNDCLOUD_GENRES.length)]
        response = Unirest.get 'http://api.soundcloud.com/tracks?client_id=%s&genres=%s&format=json&order=hotness' % [ ENV['SOUNDCLOUD_CLIENT_ID'], genre]

        new_results = response.body
                      .select { | s | s['streamable']  }
                      .collect { |x| {'type' => 'SOUNDCLOUD',
                                      'id' => x['id'],
                                      'name' => x['title'],
                                      'genre' => x['genre'],
                                      'artists' => [ x['user']['username'] ],
                                      'link' => x['permalink_url']
                                    } }
        render_and_log_to_db(json: {result: new_results[Random.rand(new_results.length)] }, status: 200)
        
        
      end
    end
    
    def play_song
      redirect_to 'spotify:track:%s' % [params['id']]
    end
  end
end

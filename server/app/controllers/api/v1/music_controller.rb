require 'unirest'

module Api::V1
  class MusicController < ApiController
    @@PROVIDER_SPOTIFY = 'spotify'
    @@PROVIDER_SOUNDCLOUD = 'soundcloud'

    @@PROVIDERS = [
      @@PROVIDER_SPOTIFY,
      @@PROVIDER_SOUNDCLOUD
    ]

    @@SOUNDCLOUD_GENRES = [
      'Alternative Rock',
      'Ambient',
      # 'Classical',
      # 'Country',
      'Dance %26 EDM',
      'Dancehall',
      'Deep House',
      'Disco',
      # 'Drum %26 Bass',
      'Dubstep',
      'Electronic',
      # 'Folk %26 Singer-Songwriter',
      'Hip-hop %26 Rap',
      'House',
      'Indie',
      # 'Jazz %26 Blues',
      # 'Latin',
      'Metal',
      # 'Piano',
      'Pop',
      'R%26B',
      # 'Reggae',
      # 'Reggaeton',
      'Rock',
      # 'Soundtrack',
      'Techno',
      'Trance',
      # 'Trap',
      # 'Triphop',
      'World',
      # 'Audiobooks',
      # 'Business',
      # 'Comedy',
      # 'Entertainment',
      # 'Learning',
      # 'News %26 Politics',
      # 'Religion %26 Spirituality',
      # 'Science',
      # 'Sports',
      # 'Storytelling',
      # 'Technology'
    ]

    @@SPOTIFY_GENRES = [
      # 'acoustic',
      # 'afrobeat',
      'alt-rock',
      'alternative',
      # 'ambient',
      'anime',
      # 'black-metal',
      # 'bluegrass',
      # 'blues',
      # 'bossanova',
      # 'brazil',
      # 'breakbeat',
      # 'british',
      'cantopop',
      # 'chicago-house',
      # 'children',
      'chill',
      # 'classical',
      'club',
      # 'comedy',
      # 'country',
      'dance',
      'dancehall',
      # 'death-metal',
      'deep-house',
      'detroit-techno',
      'disco',
      'disney',
      'drum-and-bass',
      # 'dub',
      'dubstep',
      'edm',
      'electro',
      'electronic',
      # 'emo',
      # 'folk',
      # 'forro',
      # 'french',
      # 'funk',
      # 'garage',
      # 'german',
      # 'gospel',
      # 'goth',
      # 'grindcore',
      # 'groove',
      # 'grunge',
      # 'guitar',
      # 'happy',
      # 'hard-rock',
      # 'hardcore',
      # 'hardstyle',
      'heavy-metal',
      'hip-hop',
      # 'holidays',
      # 'honky-tonk',
      'house',
      # 'idm',
      # 'indian',
      'indie',
      'indie-pop',
      # 'industrial',
      # 'iranian',
      # 'j-dance',
      # 'j-idol',
      'j-pop',
      'j-rock',
      # 'jazz',
      'k-pop',
      # 'kids',
      # 'latin',
      # 'latino',
      # 'malay',
      'mandopop',
      # 'metal',
      # 'metal-misc',
      # 'metalcore',
      'minimal-techno',
      'movies',
      # 'mpb',
      'new-age',
      'new-release',
      # 'opera',
      # 'pagode',
      'party',
      # 'philippines-opm',
      'piano',
      'pop',
      # 'pop-film',
      # 'post-dubstep',
      # 'power-pop',
      'progressive-house',
      'psych-rock',
      # 'punk',
      'punk-rock',
      'r-n-b',
      # 'rainy-day',
      # 'reggae',
      # 'reggaeton',
      # 'road-trip',
      'rock',
      # 'rock-n-roll',
      # 'rockabilly',
      # 'romance',
      # 'sad',
      # 'salsa',
      # 'samba',
      # 'sertanejo',
      # 'show-tunes',
      # 'singer-songwriter',
      # 'ska',
      # 'sleep',
      # 'songwriter',
      # 'soul',
      # 'soundtracks',
      # 'spanish',
      # 'study',
      # 'summer',
      # 'swedish',
      'synth-pop',
      # 'tango',
      'techno',
      'trance',
      # 'trip-hop',
      # 'turkish',
      'work-out',
      'world-music'
    ]

    def self.getFiveGenres
      length = @@SPOTIFY_GENRES.length
      [
        @@SPOTIFY_GENRES[Random.rand(length)],
        @@SPOTIFY_GENRES[Random.rand(length)],
        @@SPOTIFY_GENRES[Random.rand(length)],
        @@SPOTIFY_GENRES[Random.rand(length)],
        @@SPOTIFY_GENRES[Random.rand(length)]
      ]
    end

    def get_recommendation
      provider = nil
      if params['provider'] && @@PROVIDERS.include?(params['provider'].downcase)
        provider = params['provider'].downcase
      else
        provider = @@PROVIDERS[Random.rand(@@PROVIDERS.length)]
      end

      if provider == @@PROVIDER_SPOTIFY
        # TODO: Store token somewhere and only get a new token if neccessary
        access_token_response = Unirest.post 'https://accounts.spotify.com/api/token',
                                             parameters: {
                                               grant_type: 'refresh_token',
                                               refresh_token: ENV['SPOTIFY_REFRESH_TOKEN'],
                                               client_id: ENV['SPOTIFY_CLIENT_ID'],
                                               client_secret: ENV['SPOTIFY_CLIENT_SECRET']
                                             }

        access_token = access_token_response.body['access_token']
        genres = self.class.getFiveGenres
        response = Unirest.get 'https://api.spotify.com/v1/recommendations',
                               headers: { 'Authorization' => format('Bearer %s', access_token) },
                               parameters: {
                                 seed_genres: genres,
                                 market: 'US',
                                 target_popularity: Random.rand(100),
                                 target_energy: rand,
                                 target_danceability: rand,
                                 target_instrumentalness: rand,
                                 target_liveness: rand,
                                 target_speechiness: rand,
                                 target_valence: rand,
                                 limit: 20
                               }
        new_results = response.body['tracks']
                              .select { |s| s['is_playable'] }
                              .collect do |x|
          { 'type' => 'SPOTIFY',
            'id' => x['id'],
            'name' => x['name'],
            'artists' => x['artists'].collect { |y| y['name'] },
            'link' => format('https://play.spotify.com/track/%s', x['id']) }
        end
        if !new_results.empty?
          render_and_log_to_db(json: { result: new_results[Random.rand(new_results.length)] }, status: 200)
        else
          render_and_log_to_db(json: { error: 'No results' }, status: 400)
        end
      else
        genre = @@SOUNDCLOUD_GENRES[Random.rand(@@SOUNDCLOUD_GENRES.length)]
        response = Unirest.get format('http://api.soundcloud.com/tracks?client_id=%s&genres=%s&format=json&order=hotness&title=DCR300', ENV['SOUNDCLOUD_CLIENT_ID'], genre)

        new_results = response.body
                              .select { |s| s['streamable'] }
                              .collect do |x|
          { 'type' => 'SOUNDCLOUD',
            'id' => x['id'],
            'name' => x['title'],
            'genre' => x['genre'],
            'artists' => [x['user']['username']],
            'link' => x['permalink_url'] }
        end
        if !new_results.empty?
          render_and_log_to_db(json: { result: new_results[Random.rand(new_results.length)] }, status: 200)
        else
          render_and_log_to_db(json: { error: 'No results' }, status: 400)
        end
      end
    end

    def play_song
      redirect_to format('spotify:track:%s', params['id'])
    end
  end
end

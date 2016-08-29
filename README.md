SoulWalrus Website
===

ENVIRONMENT VARIABLES (Make sure you set these up or some features won't work)
---
REQUIRED environment variables:
- `POINT_SECRET` (Anything you want really...) `set POINT_SECRET=ANYTHING-YOU-WANT` (Windows) or `export POINT_SECRET=ANYTHING-YOU-WANT` (Linux)

OPTIONAL environment variables (Set the key in your environment variables with the corresponding value you get from the provider) (Needed for the various features)
- `MASHAPE_KEY` (Mashape) https://www.mashape.com/. So set `MASHAPE_KEY` to the key you get from Mashape. `set MASHAPE_KEY=YOUR-API-KEY` (Windows) or `export MASHAPE_KEY=YOUR-API-KEY` (Linux)
- `STEAM_KEY` (steam) http://steamcommunity.com/dev/apikey

  Spotify is a bit complicated, as there is an oauth flow. https://developer.spotify.com/web-api/ But you will need the following keys, and hopefully they're self explanatory
  - `SPOTIFY_REFRESH_TOKEN` 
  - `SPOTIFY_CLIENT_ID`
  - `SPOTIFY_CLIENT_SECRET`


- `SOUNDCLOUD_CLIENT_ID` (soundcloud) (Note that is is just the client id and not the secret) http://soundcloud.com/you/apps (Create an app)
- `TWITCH_CLIENT_ID` (twitch) https://www.twitch.tv/kraken/oauth2/clients/new

Setting up the database locally:
---
- Get Java
- Follow the instructions in this doc
http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html#DynamoDBLocal.DownloadingAndRunning

Setting up the server (Ruby on Rails):
---

1. Get Ruby + gems + rails http://www.tutorialspoint.com/ruby-on-rails/rails-installation.htm
or use a nice installer http://railsinstaller.org/en (Ruby 2.2)
2. Read up some docs http://www.tutorialspoint.com/ruby-on-rails/
3. run `bundle install` to install dependencies`
4. run `rails s Puma -b 0.0.0.0 -e development` in the `server` folder
5. For production `rails s Puma -b 0.0.0.0 -e production`

`bundle clean --force` to remove unused gem dependencies.

Testing if the server ran properly.
`http://localhost:3000/v1/eight_ball` should return a JSON response.

Note that the pusher.js client/secrets for `development` are hardcoded into the app atm. Feel free to change them.


Setting up the client (We're on a webpack, ES6, React stack):
---

1. Get Nodejs v6+
2. `npm install`
4. `gulp`

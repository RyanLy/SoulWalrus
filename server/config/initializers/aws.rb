require_relative '../../app/models/Motd'
require_relative '../../app/models/Streamer'
require_relative '../../app/models/Eightball'
require_relative '../../app/models/Log'
require_relative '../../app/models/SkypeSubscribe'
require_relative '../../app/models/CsgoLobby'
require_relative '../../app/models/SkypeSubscribe2'
require_relative '../../app/models/Point'
require_relative '../../app/models/PokeShuffle'
require_relative '../../app/models/User'
require_relative '../../app/models/Recent'

# Be sure to restart your server when you modify this file.

Aws.config.update(
  region: 'us-east-1'
)

if Rails.env.development?
  Aws.config.update(
    credentials: Aws::Credentials.new('REPLACE_WITH_ACCESS_KEY_ID', 'REPLACE_WITH_SECRET_ACCESS_KEY')
  )
end

# Use ssl certificate bundled with the gem package
Aws.use_bundled_cert!

p 'Creating Tables'
# DynamoDB table creations
Motd.create_table
Streamer.create_table
Eightball.create_table
Log.create_table
SkypeSubscribe.create_table
CsgoLobby.create_table
SkypeSubscribe2.create_table
Point.create_table
PokeShuffle.create_table
User.create_table
Recent.create_table

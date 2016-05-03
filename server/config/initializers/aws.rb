require_relative '../../app/models/Motd'
require_relative '../../app/models/Streamer'
require_relative '../../app/models/Eightball'
require_relative '../../app/models/Log'
require_relative '../../app/models/SkypeSubscribe'

# Be sure to restart your server when you modify this file.

Aws.config.update({
  region: 'us-east-1'
})

# Use ssl certificate bundled with the gem package
Aws.use_bundled_cert!

p 'Creating Tables'
# DynamoDB table creations
Motd.create_table
Streamer.create_table
Eightball.create_table
Log.create_table
SkypeSubscribe.create_table

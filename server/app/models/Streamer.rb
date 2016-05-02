class Streamer
  include Dynamoid::Document

  table :name => :streamers, :key => :_id
  
  field :_id
  field :_links
  field :created_at
  field :display_name
  field :name
  field :stream
  field :updated_at
  field :submitted_at, :datetime, {default: ->(){Time.now}}
  field :submitted_by
  field :online
end

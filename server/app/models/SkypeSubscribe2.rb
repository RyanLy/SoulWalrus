class SkypeSubscribe2
  include Dynamoid::Document

  table :name => :skype_subscribe2, :key => :convo_id

  field :convo_id
  field :channelId
  field :user, :serialized
  field :conversation, :serialized
  field :bot, :serialized
  field :serviceUrl
  field :useAuth
end

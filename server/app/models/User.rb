class User
  include Dynamoid::Document
  table name: :user, key: :user_id
  range :friendly_id

  field :lock_version, :integer
  field :user_id
  field :friendly_id, :integer
  field :user_name
  field :points, :array
  field :label
  field :names, :array

  global_secondary_index hash_key: :friendly_id
  global_secondary_index hash_key: :user_name

  validates_presence_of :user_id
  validates_presence_of :friendly_id
end

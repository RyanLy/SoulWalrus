class UserPoint
  include Dynamoid::Document
  table name: :user_point, key: :user_id
  range :friendly_id

  field :lock_version, :integer
  field :user_id
  field :friendly_id, :integer
  field :points, :array

  global_secondary_index hash_key: :user_id, projected_attributes: :all

  validates_presence_of :user_id
  validates_presence_of :friendly_id
end

class User
  include Dynamoid::Document
  table name: :user, key: :user_id

  field :lock_version, :integer
  field :user_id
  field :user_name
  field :names, :array

  validates_presence_of :user_id
  validates_presence_of :user_name
end

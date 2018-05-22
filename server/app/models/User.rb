class User
  include Dynamoid::Document
  table :name => :user, :key => :user_id

  field :user_name
  field :user_id
  field :value, :integer
  field :points, :serialized # id => array of points
  field :label
  field :names, :array
end

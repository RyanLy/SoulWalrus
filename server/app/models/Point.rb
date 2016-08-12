class Point
  include Dynamoid::Document

  table :name => :point, :key => :id

  field :user, :serialized
  field :points
  field :description
  field :friendly_id
  field :friendly_name
end

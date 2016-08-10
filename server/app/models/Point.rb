class Point
  include Dynamoid::Document

  table :name => :point, :key => :id

  field :user, :serialized
  field :points
  field :description
end

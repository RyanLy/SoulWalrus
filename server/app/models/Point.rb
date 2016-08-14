class Point
  include Dynamoid::Document

  table :name => :point, :key => :id
  range :create_date, :datetime

  field :user, :serialized
  field :points
  field :description
  field :friendly_id
  field :friendly_name
  field :user_name
  field :user_id
  field :capture_date, :datetime
end

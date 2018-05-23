class Point
  include Dynamoid::Document
  table :name => :point, :key => :id

  field :user, :serialized
  field :points
  field :description
  field :friendly_id
  field :value
  field :friendly_name
  field :user_name
  field :user_id
  field :create_date, :datetime
  field :capture_date, :datetime
end

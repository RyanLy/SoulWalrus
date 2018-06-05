class Point
  include Dynamoid::Document
  table name: :point, key: :id

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

  global_secondary_index hash_key: :friendly_id, projected_attributes: :all

  def self.get_id_weight(id)
    if id > 251
      ((id - 251) * 151.0 / 135).round(2)
    elsif id > 151
      (id - 151) * 151.0 / 100
    else
      id
    end
  end

  def self.calculate_points(points)
    point = 0
    points.each do |id, number|
      point += (number.length * Point.get_id_weight(id))
    end

    point.round(2)
  end

  def self.get_best_point(points)
    results = {}
    points.each do |id, _value|
      results[Point.get_id_weight(id)] = id
    end
    results.max.last
  end
end

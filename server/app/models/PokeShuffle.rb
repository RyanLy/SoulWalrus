class PokeShuffle
  include Dynamoid::Document
  table name: :poke_shuffle, key: :id

  field :point_id
  field :user_id
end

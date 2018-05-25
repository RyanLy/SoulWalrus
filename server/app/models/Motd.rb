class Motd
  include Dynamoid::Document

  table name: :motd, key: :id

  field :message
  field :submitted_by
end

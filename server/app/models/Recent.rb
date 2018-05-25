class Recent
  include Dynamoid::Document
  table name: :recent, key: :id

  field :id
end

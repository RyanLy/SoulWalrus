class Log
  include Dynamoid::Document

  table name: :logs, key: :action
  range :created_at, :datetime

  field :controller
  field :action
  field :params
  field :result
end

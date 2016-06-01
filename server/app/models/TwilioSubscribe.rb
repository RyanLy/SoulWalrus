class TwilioSubscribe
  include Dynamoid::Document

  table :name => :twilio_subscribe, :key => :id

  field :number
  field :submitted_by
  field :valid
end

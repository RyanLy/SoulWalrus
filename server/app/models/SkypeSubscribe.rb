class SkypeSubscribe
  include Dynamoid::Document

  table :name => :skype_subscribe, :key => :id

  field :chatid
  field :submitted_by
  field :valid
end

class CsgoLobby
  include Dynamoid::Document

  table :name => :csgo_lobby, :key => :id

  field :id
  field :lobbyid
  
end

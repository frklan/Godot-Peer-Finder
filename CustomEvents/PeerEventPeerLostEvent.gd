class_name PeerEventPeerLost

var peer_address: String
var peer_port: int

func _init(dict: Dictionary):
  peer_address = dict["peer_address"] 
  peer_port = dict["peer_port"]

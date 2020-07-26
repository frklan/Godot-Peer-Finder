class_name PeerEventPeerFound

var peer_address: String
var peer_port: int
var packet_payload: String

func _init(dict: Dictionary):
  peer_address = dict["peer_address"] 
  peer_port = dict["peer_port"] 
  packet_payload = dict["packet_payload"]
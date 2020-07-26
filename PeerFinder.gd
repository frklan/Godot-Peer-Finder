# A node that sends a UDP broadcast on port 35434 and 
# identifies any other peers doing the same.

extends Node

# warning-ignore-all:return_value_discarded
# warning-ignore-all:unused_signal

signal server_started
signal server_stopped
signal peer_found
signal peer_lost

onready var txTimer: Timer = Timer.new()
onready var peerLostTimer: Timer = Timer.new()
onready var packetPeer: PacketPeerUDP = PacketPeerUDP.new()

const PEER_TIMEOUT_S := 5
const DEFAULT_PORT := 35434

var remotePeers := [{}]

# --------------
# Public methods
# --------------

# Start broadcasting our presens and starts looking for other peers
# Can return eny of these:
# OK - No error
# ERR_UNAVAILABLE
# ERR_ALREADY_IN_USE
# ERR_INVALID_PARAMETER
func start():
  remotePeers.clear()
  print("PeerFinder::start()")
  packetPeer.set_broadcast_enabled(true)
  var err = packetPeer.set_dest_address("255.255.255.255", DEFAULT_PORT) # Will only return ERR_CANT_RESOLVE which we should never be able to get here
  assert(err == OK, str("Could not resolve broadcast address (%d)" % err))
  
  err = packetPeer.listen(DEFAULT_PORT)
  if err != OK:
    return err

  txTimer.start(1)
  peerLostTimer.start(1)
  emit_signal("server_started")

  return OK

# Stops looking for other peers and terminates the broadcast of our presens
func stop():
  print("PeerFinder::stop()")
  txTimer.stop()
  peerLostTimer.stop()
  packetPeer.close()
  emit_signal("server_stopped")

# ---------------
# Private methods
# ---------------

func _ready():
  print("PeerFinder ready!")
  txTimer.autostart = false
  txTimer.connect("timeout", self, "on_txTimer_timeout")
  txTimer.set_one_shot(false)
  add_child(txTimer)

  peerLostTimer.autostart = false
  peerLostTimer.connect("timeout", self, "on_peerLostTimer_timeout")
  peerLostTimer.set_one_shot(false)
  add_child(peerLostTimer)

func is_address_local(address: String):
  return IP.get_local_addresses().has(address)

func _process(_delta):
  if packetPeer.get_available_packet_count() > 0:
    var packet = packetPeer.get_packet()
    var packetPayload = packet.get_string_from_utf8()
    var remotePeerAddress: String = packetPeer.get_packet_ip()
    var remotePeerPort: int = packetPeer.get_packet_port()
    
    if !is_address_local(remotePeerAddress) && remotePeerAddress.length() > 0:
      if isPeerKnown(remotePeerAddress): # We know this peer..
        for i in remotePeers.size(): #..find peer in list and update timeout
          if remotePeers[i].peer_address == remotePeerAddress && remotePeers[i].peer_port == remotePeerPort:
            remotePeers[i].timeout = OS.get_unix_time() + PEER_TIMEOUT_S
      else: # New peer, store it in list and signal client
        remotePeers.push_back({
          "peer_address": remotePeerAddress,
          "peer_port": remotePeerPort,
          "timeout": OS.get_unix_time() + PEER_TIMEOUT_S
        })
        emit_signal("peer_found", PeerEventPeerFound.new({
          "peer_address": remotePeerAddress,
          "peer_port": remotePeerPort,
          "packet_payload": packetPayload
        }))

func isPeerKnown(peerAddress: String):
  for peer in remotePeers:
    if peer["peer_address"] == peerAddress:
      return true
  return false

# Signals
func on_txTimer_timeout():
  # put_var mmight return these ERR_UNCONFIGURED, ERR_INVALID_PARAMETER, ERR_UNAVAILABLE, ERR_BUG, FAILED
  # most of these should never happen here so assert return.
  var err = packetPeer.put_var({
    "message": "Hello"
  })
  assert(err == OK, str("Could not broadcast data (%d)" % err))

func on_peerLostTimer_timeout():
  var t := []

  # iterate over all peers, remote those we've not seen
  # in the last PEER_TIMEOUT_S seconds and signal client
  for i in remotePeers.size():
    var p = remotePeers[i]
    if p["timeout"] < OS.get_unix_time():
      emit_signal("peer_lost", PeerEventPeerLost.new({
        "peer_address": p["peer_address"],
        "peer_port": p["peer_port"]
      }))
    else:
      t.append(p)

  remotePeers = t.duplicate(true)

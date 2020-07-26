# Godot-Peer-Finder

Godot-Peer-Finder is a script that finds other instances on the same subnet by sending and receiveing UDP packets on port 35434.

## How to use

- Download the latest release from [https://github.com/frklan/Godot-Peer-Finder](https://github.com/frklan/Godot-Peer-Finder) somewhere in your project (e.g. as a sumbodule)
- Autoload the ´´´PeerFinder.gd´´´script in Godot (i.e. Project Settings -> Autoload)
- At a minimum, connect to the ```peer_found```and ```peer_lost``` signals, then call PeerFinder.start()

## Documentation

### Methods

## Start()

Starts the PeerFinder listening for peers and broadcasting it's existance.

### Stop()

Stops the PeerFiner listening and broadcasting

### Signals

| Name                  | Signal          | Argument                                   |
|-----------------------|-----------------|--------------------------------------------|
| Server started        | server_started  | None                                       |
| Server stopped        | server_stopped  | None                                       |
| New peer found        | peer_found      | [PeerEventPeerFound](#PeerEventPeerFound)  |
| Per lost/dissapeard   | peer_lost       | [PeerEventPeerLost](#PeerEventPeerLost)    |

#### PeerEventPeerFound

An event that is dispatched when a new peer is discovered. Note the event will be dispatched again if the peer was previously seen and subsequently lost and rediscovered.

***Properties***

- peer_address: ***String*** A string containing the IP address of the remote peer
- peer_port: ***int*** The port the Peer appeared at (will always be 35434)
- packet_payload: ***String*** A string sent by the remote peer, currently hardcoded to "Hello"

#### PeerEventPeerLost

An event sent when the PeerFinder has not received a UDP packet from the peer for more than 5 seconds

***Properties***

- peer_address: ***String*** A string containing the IP address of the remote peer
- peer_port: ***int*** The port the Peer appeared at (will always be 35434)

## Contributing

Contributions are always welcome!

When contributing to this repository, please first discuss the change you wish to make via the issue tracker, email, or any other method with the owner of this repository before making a change.

Please note that we have a code of conduct, you are required to follow it in all your interactions with the project.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/frklan/[TBD]/tags).

## Authors

- **Fredrik Andersson** - [frklan](https://github.com/frklan)

## License

This project is licensed under the CC BY-NC-SA License - see the [LICENSE](LICENSE) file for details

For commercial/proprietary licensing, please contact the project owner

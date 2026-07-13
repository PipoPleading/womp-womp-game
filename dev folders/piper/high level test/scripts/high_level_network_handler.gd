extends Node

const IP_ADDRESS : String = "localhost"
const PORT : int = 50000

var peer : ENetMultiplayerPeer

func start_server() -> void:
	print("server started")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	print("client started")
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

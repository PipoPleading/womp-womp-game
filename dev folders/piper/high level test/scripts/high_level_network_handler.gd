extends Node

const IP_ADDRESS : String = "localhost"
const PORT : int = 50000

var peer : ENetMultiplayerPeer

##outline of what needs to be done for better multiplayer handling
# have export of game and see if netplay is possible
# from there, iron out bugs like someone being a relative server/client
# IP_parsing is probably gonna be needed, also unique id per instance

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

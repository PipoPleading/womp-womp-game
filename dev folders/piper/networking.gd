extends Node

signal host_created()
signal lobby_joined()
signal lobby_join_failed(reason: String)
signal lobby_members_updated()
signal kicked_from_lobby()

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer: SteamMultiplayerPeer
var lobby_id: int = 0

# Godot multiplayer peer id (int) -> Steam ID (int), for everyone but us.
# Steam has no public/short lobby-invite code, so the "lobby code" players
# share is just the Steam lobby id as a string.
var _peer_steam_ids: Dictionary = {}


func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _process(delta: float) -> void:
	Steam.run_callbacks()


func host_lobby(max_members: int) -> void:
	Steam.createLobby(LOBBY_TYPE, clampi(max_members, 1, MAX_MEMBERS))


func get_lobby_code() -> String:
	return str(lobby_id)


func join_lobby(code: String) -> void:
	if not code.is_valid_int():
		lobby_join_failed.emit("That doesn't look like a lobby code.")
		return
	Steam.joinLobby(code.to_int())


func leave_lobby() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
	multiplayer.multiplayer_peer = null
	peer = null
	lobby_id = 0
	_peer_steam_ids.clear()


func is_local_player_owner() -> bool:
	return lobby_id != 0 and Steam.getLobbyOwner(lobby_id) == Steam.getSteamID()


## Includes the local player. Each entry: peer_id, steam_id, name, is_owner.
func get_lobby_members() -> Array[Dictionary]:
	var members : Array[Dictionary] = []
	if lobby_id == 0:
		return members

	members.append({
		"peer_id": multiplayer.get_unique_id(),
		"steam_id": Steam.getSteamID(),
		"name": Steam.getPersonaName(),
		"is_owner": is_local_player_owner(),
	})
	for peer_id in _peer_steam_ids:
		var steam_id : int = _peer_steam_ids[peer_id]
		members.append({
			"peer_id": peer_id,
			"steam_id": steam_id,
			"name": Steam.getFriendPersonaName(steam_id),
			"is_owner": Steam.getLobbyOwner(lobby_id) == steam_id,
		})
	return members


## Steamworks has no forced-kick API - only a member can remove themselves
## from a lobby. As host we disconnect them at the multiplayer layer and
## tell their client to leave the Steam lobby on their own.
func kick_player(peer_id: int) -> void:
	if not is_local_player_owner() or peer_id == multiplayer.get_unique_id():
		return
	_notify_kicked.rpc_id(peer_id)
	if peer:
		peer.disconnect_peer(peer_id)


func promote_player(steam_id: int) -> void:
	if not is_local_player_owner():
		return
	Steam.setLobbyOwner(lobby_id, steam_id)
	lobby_members_updated.emit()


func start_game() -> void:
	if is_local_player_owner():
		_start_game.rpc()


@rpc("authority", "call_local", "reliable")
func _start_game() -> void:
	GameManager.start_game.emit()


@rpc("authority", "call_remote", "reliable")
func _notify_kicked() -> void:
	kicked_from_lobby.emit()
	leave_lobby()


@rpc("any_peer", "call_remote", "reliable")
func _announce_steam_id(steam_id: int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	_peer_steam_ids[sender_id] = steam_id
	lobby_members_updated.emit()


func _on_peer_connected(id: int) -> void:
	_announce_steam_id.rpc_id(id, Steam.getSteamID())


func _on_peer_disconnected(id: int) -> void:
	if _peer_steam_ids.erase(id):
		lobby_members_updated.emit()


func _on_lobby_chat_update(_lobby_id: int, _changed_id: int, _making_change_id: int, _chat_state: int) -> void:
	lobby_members_updated.emit()


func on_lobby_created(connect: int, new_lobby_id: int) -> void:
	if connect == Steam.RESULT_OK:
		lobby_id = new_lobby_id
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()


func on_lobby_joined(joined_lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_join_failed.emit("Could not join lobby %s." % joined_lobby_id)
		return

	lobby_id = joined_lobby_id
	if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
		return
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(lobby_id))
	multiplayer.multiplayer_peer = peer
	lobby_joined.emit()


# Called when attempting to join from the Steam interface
func on_join_requested(lobby_id: int, steam_id: int) -> void:
	# Will cause the "lobby_joined" signal to emit
	Steam.joinLobby(lobby_id)

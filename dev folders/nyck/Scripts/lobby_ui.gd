extends Control


const MIN_PLAYERS_TO_START := 2
const MAX_PLAYERS := 4

const MAIN_MENU_SCENE_PATH := "uid://l8fph7u0swoq"

@onready var kitchen_background: Node = $KitchenBackground
@onready var back_button: Button = $BackButton

@onready var join_create_panel: Panel = $JoinCreatePanel
@onready var create_lobby_button: Button = $JoinCreatePanel/CreateLobbyButton
@onready var join_lobby_button: Button = $JoinCreatePanel/JoinLobbyButton

@onready var create_lobby_panel: Panel = $CreateLobbyPanel
@onready var player_count_spinbox: SpinBox = $CreateLobbyPanel/PlayerCountSpinBox
@onready var confirm_create_button: Button = $CreateLobbyPanel/ConfirmCreateButton
@onready var cancel_create_button: Button = $CreateLobbyPanel/CancelCreateButton

@onready var join_lobby_panel: Panel = $JoinLobbyPanel
@onready var lobby_code_input: LineEdit = $JoinLobbyPanel/LobbyCodeInput
@onready var join_confirm_button: Button = $JoinLobbyPanel/JoinConfirmButton
@onready var cancel_join_button: Button = $JoinLobbyPanel/CancelJoinButton
@onready var join_error_label: Label = $JoinLobbyPanel/ErrorLabel

@onready var lobby_room_panel: Panel = $LobbyRoomPanel
@onready var lobby_code_label: Label = $LobbyRoomPanel/LobbyCodeLabel
@onready var player_list_container: VBoxContainer = $LobbyRoomPanel/PlayerListContainer
@onready var start_game_button: Button = $LobbyRoomPanel/StartGameButton


var _lobby_id: int = 0
var _peer_steam_ids: Dictionary = {}


func _ready() -> void:
	_hide_menu_background_ui()

	back_button.pressed.connect(_on_back_pressed)

	create_lobby_button.pressed.connect(_show_panel.bind(create_lobby_panel))
	join_lobby_button.pressed.connect(_show_panel.bind(join_lobby_panel))
	cancel_create_button.pressed.connect(_show_panel.bind(join_create_panel))
	cancel_join_button.pressed.connect(_show_panel.bind(join_create_panel))

	confirm_create_button.pressed.connect(_on_confirm_create_pressed)
	join_confirm_button.pressed.connect(_on_join_confirm_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)

	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_joined.connect(_on_steam_lobby_joined)
	Steam.lobby_chat_update.connect(_on_steam_lobby_chat_update)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	join_error_label.hide()
	_show_panel(join_create_panel)


func _hide_menu_background_ui() -> void:
	for node_name in ["Title", "PlayButton", "OptionsButton", "QuitButton", "OptionsPanel"]:
		var node : Node = kitchen_background.get_node_or_null(node_name)
		if node:
			node.hide()

	var viewport_container : Node = kitchen_background.get_node_or_null("SubViewportContainer")
	if viewport_container is Control:
		viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg_music : Node = kitchen_background.get_node_or_null("MusicPlayer")
	if bg_music is AudioStreamPlayer:
		bg_music.stop()


func _show_panel(panel: Control) -> void:
	join_create_panel.hide()
	create_lobby_panel.hide()
	join_lobby_panel.hide()
	lobby_room_panel.hide()
	panel.show()


func _on_confirm_create_pressed() -> void:
	
	Steam.createLobby(Networking.LOBBY_TYPE, clampi(int(player_count_spinbox.value), 1, MAX_PLAYERS))


func _on_join_confirm_pressed() -> void:
	join_error_label.hide()
	var code := lobby_code_input.text.strip_edges()
	if not code.is_valid_int():
		_on_lobby_join_failed("That doesn't look like a lobby code.")
		return
	Steam.joinLobby(code.to_int())


func _on_steam_lobby_created(connect: int, new_lobby_id: int) -> void:
	if connect == Steam.RESULT_OK:
		_lobby_id = new_lobby_id
		_on_lobby_ready()


func _on_steam_lobby_joined(joined_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		_on_lobby_join_failed("Could not join lobby %s." % joined_lobby_id)
		return

	_lobby_id = joined_lobby_id
	if Steam.getLobbyOwner(_lobby_id) == Steam.getSteamID():
		return # We're the host; _on_steam_lobby_created already handled this.
	_on_lobby_ready()


func _on_lobby_join_failed(reason: String) -> void:
	join_error_label.text = reason
	join_error_label.show()


func _on_lobby_ready() -> void:
	_show_panel(lobby_room_panel)
	lobby_code_label.text = "Lobby Code: %s" % str(_lobby_id)
	_refresh_player_list()


func _is_local_player_owner() -> bool:
	return _lobby_id != 0 and Steam.getLobbyOwner(_lobby_id) == Steam.getSteamID()


## Includes the local player. Each entry: peer_id, steam_id, name, is_owner.
func _get_lobby_members() -> Array[Dictionary]:
	var members : Array[Dictionary] = []
	if _lobby_id == 0:
		return members

	members.append({
		"peer_id": multiplayer.get_unique_id(),
		"steam_id": Steam.getSteamID(),
		"name": Steam.getPersonaName(),
		"is_owner": _is_local_player_owner(),
	})
	for peer_id in _peer_steam_ids:
		var steam_id : int = _peer_steam_ids[peer_id]
		members.append({
			"peer_id": peer_id,
			"steam_id": steam_id,
			"name": Steam.getFriendPersonaName(steam_id),
			"is_owner": Steam.getLobbyOwner(_lobby_id) == steam_id,
		})
	return members


func _refresh_player_list() -> void:
	for child in player_list_container.get_children():
		child.queue_free()

	var members : Array[Dictionary] = _get_lobby_members()
	var am_owner : bool = _is_local_player_owner()

	for member in members:
		var row := HBoxContainer.new()

		var name_label := Label.new()
		name_label.text = member["name"] + (" (Host)" if member["is_owner"] else "")
		name_label.custom_minimum_size.x = 160
		row.add_child(name_label)

		if am_owner and not member["is_owner"]:
			var kick_button := Button.new()
			kick_button.text = "Kick"
			kick_button.pressed.connect(_kick_player.bind(member["peer_id"]))
			row.add_child(kick_button)

			var promote_button := Button.new()
			promote_button.text = "Promote"
			promote_button.pressed.connect(_promote_player.bind(member["steam_id"]))
			row.add_child(promote_button)

		player_list_container.add_child(row)

	start_game_button.visible = am_owner and members.size() >= MIN_PLAYERS_TO_START



func _kick_player(peer_id: int) -> void:
	if not _is_local_player_owner() or peer_id == multiplayer.get_unique_id():
		return
	_notify_kicked.rpc_id(peer_id)
	if Networking.peer:
		Networking.peer.disconnect_peer(peer_id)


func _promote_player(steam_id: int) -> void:
	if not _is_local_player_owner():
		return
	Steam.setLobbyOwner(_lobby_id, steam_id)
	_refresh_player_list()


func _on_start_game_pressed() -> void:
	if _is_local_player_owner():
		_start_game.rpc()


@rpc("authority", "call_local", "reliable")
func _start_game() -> void:
	GameManager.start_game.emit()


@rpc("authority", "call_remote", "reliable")
func _notify_kicked() -> void:
	_on_kicked_from_lobby()
	_leave_lobby()


@rpc("any_peer", "call_remote", "reliable")
func _announce_steam_id(steam_id: int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	_peer_steam_ids[sender_id] = steam_id
	_refresh_player_list()


func _on_peer_connected(id: int) -> void:
	_announce_steam_id.rpc_id(id, Steam.getSteamID())


func _on_peer_disconnected(id: int) -> void:
	if _peer_steam_ids.erase(id):
		_refresh_player_list()


func _on_steam_lobby_chat_update(_lobby: int, _changed_id: int, _making_change_id: int, _chat_state: int) -> void:
	_refresh_player_list()


func _on_kicked_from_lobby() -> void:
	_show_panel(join_create_panel)


func _on_back_pressed() -> void:
	_leave_lobby()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _leave_lobby() -> void:
	if _lobby_id != 0:
		Steam.leaveLobby(_lobby_id)
	multiplayer.multiplayer_peer = null
	Networking.peer = null
	_lobby_id = 0
	_peer_steam_ids.clear()

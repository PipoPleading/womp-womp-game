extends Control


const MIN_PLAYERS_TO_START := 2

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

	Networking.host_created.connect(_on_lobby_ready)
	Networking.lobby_joined.connect(_on_lobby_ready)
	Networking.lobby_join_failed.connect(_on_lobby_join_failed)
	Networking.lobby_members_updated.connect(_refresh_player_list)
	Networking.kicked_from_lobby.connect(_on_kicked_from_lobby)

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


func _show_panel(panel: Control) -> void:
	join_create_panel.hide()
	create_lobby_panel.hide()
	join_lobby_panel.hide()
	lobby_room_panel.hide()
	panel.show()


func _on_confirm_create_pressed() -> void:
	Networking.host_lobby(int(player_count_spinbox.value))


func _on_join_confirm_pressed() -> void:
	join_error_label.hide()
	Networking.join_lobby(lobby_code_input.text.strip_edges())


func _on_lobby_join_failed(reason: String) -> void:
	join_error_label.text = reason
	join_error_label.show()


func _on_lobby_ready() -> void:
	_show_panel(lobby_room_panel)
	lobby_code_label.text = "Lobby Code: %s" % Networking.get_lobby_code()
	_refresh_player_list()


func _refresh_player_list() -> void:
	for child in player_list_container.get_children():
		child.queue_free()

	var members : Array[Dictionary] = Networking.get_lobby_members()
	var am_owner : bool = Networking.is_local_player_owner()

	for member in members:
		var row := HBoxContainer.new()

		var name_label := Label.new()
		name_label.text = member["name"] + (" (Host)" if member["is_owner"] else "")
		name_label.custom_minimum_size.x = 160
		row.add_child(name_label)

		if am_owner and not member["is_owner"]:
			var kick_button := Button.new()
			kick_button.text = "Kick"
			kick_button.pressed.connect(Networking.kick_player.bind(member["peer_id"]))
			row.add_child(kick_button)

			var promote_button := Button.new()
			promote_button.text = "Promote"
			promote_button.pressed.connect(Networking.promote_player.bind(member["steam_id"]))
			row.add_child(promote_button)

		player_list_container.add_child(row)

	start_game_button.visible = am_owner and members.size() >= MIN_PLAYERS_TO_START


func _on_start_game_pressed() -> void:
	Networking.start_game()


func _on_kicked_from_lobby() -> void:
	_show_panel(join_create_panel)


func _on_back_pressed() -> void:
	Networking.leave_lobby()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

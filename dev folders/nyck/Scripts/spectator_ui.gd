extends Control

## Players that can be spectated must add themselves to the "alive_players"
## group on spawn and remove themselves from it when they die.

const MAIN_MENU_SCENE_PATH := "uid://l8fph7u0swoq"
const LOBBY_SCENE_PATH := "uid://d2c6ovqh5tdyt"

@onready var name_label: Label = $Label
@onready var leave_lobby_button: Button = $Button
@onready var return_button: Button = $Button2
@onready var left_button: Button = $Control/LeftButton
@onready var right_button: Button = $Control/RightButton

var _spectate_index: int = 0


func _ready() -> void:
	leave_lobby_button.pressed.connect(_on_leave_lobby_pressed)
	return_button.pressed.connect(_on_return_pressed)
	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	_update_spectated_player()


func _get_alive_players() -> Array[Node]:
	return get_tree().get_nodes_in_group("alive_players")


func _update_spectated_player() -> void:
	var alive := _get_alive_players()
	if alive.is_empty():
		name_label.text = ""
		return

	_spectate_index = wrapi(_spectate_index, 0, alive.size())
	var target : Node = alive[_spectate_index]
	name_label.text = target.name
	# TODO: once a spectator camera exists, point it at `target` here.


func _on_left_pressed() -> void:
	_spectate_index -= 1
	_update_spectated_player()


func _on_right_pressed() -> void:
	_spectate_index += 1
	_update_spectated_player()


func _on_leave_lobby_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _on_return_pressed() -> void:
	if ResourceLoader.exists(LOBBY_SCENE_PATH):
		get_tree().change_scene_to_file(LOBBY_SCENE_PATH)
	else:
		push_warning("Lobby scene not created yet: %s" % LOBBY_SCENE_PATH)

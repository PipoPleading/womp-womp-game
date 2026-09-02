extends Control


const MAIN_MENU_SCENE_PATH := "uid://l8fph7u0swoq"
const LOBBY_SCENE_PATH := "uid://d2c6ovqh5tdyt"

@onready var menu_panel: Panel = $MenuPanel
@onready var resume_button: Button = $MenuPanel/ResumeButton
@onready var options_button: Button = $MenuPanel/OptionsButton
@onready var leave_button: Button = $MenuPanel/LeaveButton

@onready var options_panel: Panel = $OptionsPanel
@onready var volume_slider: HSlider = $OptionsPanel/VolumeSlider
@onready var close_options_button: Button = $OptionsPanel/CloseButton

@onready var leave_confirm_panel: Panel = $LeaveConfirmPanel
@onready var leave_game_button: Button = $LeaveConfirmPanel/LeaveGameButton
@onready var leave_lobby_button: Button = $LeaveConfirmPanel/LeaveLobbyButton
@onready var cancel_leave_button: Button = $LeaveConfirmPanel/CancelButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	leave_button.pressed.connect(_on_leave_pressed)

	close_options_button.pressed.connect(_on_close_options_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

	leave_game_button.pressed.connect(_on_leave_game_pressed)
	leave_lobby_button.pressed.connect(_on_leave_lobby_pressed)
	cancel_leave_button.pressed.connect(_on_cancel_leave_pressed)

	var master_bus := AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus)) * 100.0

	hide()
	options_panel.hide()
	leave_confirm_panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause_menu()
		get_viewport().set_input_as_handled()


func _toggle_pause_menu() -> void:
	if visible:
		_close_pause_menu()
	else:
		_open_pause_menu()


func _open_pause_menu() -> void:
	show()
	menu_panel.show()
	options_panel.hide()
	leave_confirm_panel.hide()
	get_tree().paused = true


func _close_pause_menu() -> void:
	hide()
	get_tree().paused = false


func _on_resume_pressed() -> void:
	_close_pause_menu()


func _on_options_pressed() -> void:
	menu_panel.hide()
	options_panel.show()


func _on_close_options_pressed() -> void:
	options_panel.hide()
	menu_panel.show()


func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value / 100.0))


func _on_leave_pressed() -> void:
	menu_panel.hide()
	leave_confirm_panel.show()


func _on_cancel_leave_pressed() -> void:
	leave_confirm_panel.hide()
	menu_panel.show()


func _on_leave_game_pressed() -> void:
	get_tree().paused = false
	if ResourceLoader.exists(LOBBY_SCENE_PATH):
		get_tree().change_scene_to_file(LOBBY_SCENE_PATH)
	else:
		push_warning("Lobby scene not created yet: %s" % LOBBY_SCENE_PATH)


func _on_leave_lobby_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

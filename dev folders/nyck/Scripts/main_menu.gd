extends Node3D

const LOBBY_SCENE_PATH := "uid://d2c6ovqh5tdyt"

@onready var play_button: Button = $PlayButton
@onready var options_button: Button = $OptionsButton
@onready var quit_button: Button = $QuitButton

@onready var options_panel: Panel = $OptionsPanel
@onready var volume_slider: HSlider = $OptionsPanel/VolumeSlider
@onready var close_options_button: Button = $OptionsPanel/CloseButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_options_button.pressed.connect(_on_close_options_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

	options_panel.hide()
	var master_bus := AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus)) * 100.0


func _on_play_pressed() -> void:
	if ResourceLoader.exists(LOBBY_SCENE_PATH):
		get_tree().change_scene_to_file(LOBBY_SCENE_PATH)
	else:
		push_warning("Lobby scene not created yet: %s" % LOBBY_SCENE_PATH)


func _on_options_pressed() -> void:
	options_panel.visible = not options_panel.visible


func _on_close_options_pressed() -> void:
	options_panel.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value / 100.0))

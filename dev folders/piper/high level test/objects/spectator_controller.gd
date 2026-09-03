extends Node3D
@onready var spectator_ui: Control = %SpectatorUI
@onready var spectator_camera: PhantomCamera3D = $Spectator_Camera

func _ready() -> void:
	spectator_ui.hide()
	GameManager.dead.connect(test)
	pass

func test():
	if is_multiplayer_authority():
		spectator_camera.priority = 15
		spectator_ui.show()

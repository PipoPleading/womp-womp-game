extends Camera3D

@onready var spectator_ui: Control = $SpectatorUI

func _ready() -> void:
	pass

func test():
	print(PhantomCameraManager.phantom_camera_3ds)

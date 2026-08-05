extends WeaponData
class_name FryingPan

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func attack(pivot_point: Node3D, tween: Tween) -> void:
	if is_attacking:
		return
	else:
		is_attacking = true

	tween.tween_property(pivot_point, "rotation_degrees", Vector3(-10, 5, 0), 0.125).as_relative()
	for i in range(4):
		tween.tween_property(pivot_point, "rotation_degrees", Vector3(4, -2, 0), 0.125).as_relative()
		tween.tween_property(pivot_point, "rotation_degrees", Vector3(-4, 2, 0), 0.125).as_relative()

	tween.tween_property(pivot_point, "rotation_degrees", Vector3(100, -50, 0), 0.25).as_relative()
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(-90, 45, 0), 0.5).as_relative()
	
	tween.finished.connect(func(): is_attacking = false)

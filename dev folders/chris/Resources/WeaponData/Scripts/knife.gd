extends WeaponData
class_name Knife

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
	
	#TODO: Make player leave trail
	#TODO: Add splatter particles
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(90, 0, 0), 0.2).as_relative()
	tween.tween_property(pivot_point, "position", Vector3(0, 0, 0.3), 0.2).as_relative()
	tween.tween_property(pivot_point, "position", Vector3(0, 0, -0.3), 0.2).as_relative()
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(-90, 0, 0), 0.2).as_relative()
	
	tween.finished.connect(func(): is_attacking = false)

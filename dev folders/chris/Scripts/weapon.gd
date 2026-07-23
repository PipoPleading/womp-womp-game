extends Node
class_name Weapon

@export var weapon_data : WeaponData
@export var pivot_point : Node3D
var is_attacking : bool = false

func attack() -> void:
	if is_attacking:
		return
	else:
		is_attacking = true
	
	var tween = create_tween()
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(90, -45, 0), 0.5).as_relative()
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(-90, 45, 0), 2).as_relative()
	
	tween.finished.connect(func(): is_attacking = false)

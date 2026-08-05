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
	tween.finished.connect(func(): is_attacking = false)

	weapon_data.attack(pivot_point, tween)

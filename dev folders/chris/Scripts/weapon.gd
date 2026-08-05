extends Node
class_name Weapon

@export var weapon_data : WeaponData
@export var pivot_point : Node3D
var is_attacking : bool = false

func attack() -> void:
	var tween = create_tween()
	
	weapon_data.attack(pivot_point, tween)

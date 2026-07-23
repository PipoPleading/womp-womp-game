extends Node
class_name Weapon

@export var weapon_data : WeaponData
@export var pivot_point : Node3D
var is_attacking : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func attack() -> void:
	if is_attacking:
		return
	else:
		is_attacking = true
	
	var tween = create_tween()
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(90, -45, 0), 0.5).as_relative()
	tween.tween_property(pivot_point, "rotation_degrees", Vector3(-90, 45, 0), 2).as_relative()
	
	tween.finished.connect(func(): is_attacking = false)

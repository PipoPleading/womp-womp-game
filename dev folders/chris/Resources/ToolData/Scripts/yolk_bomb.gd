extends ToolData
class_name YolkBomb

var deployable = preload("res://dev folders/chris/Tools/yolk_bomb_deployable.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func attack(pivot_point: Node3D, tween: Tween) -> void:
	tween.tween_property(pivot_point, "position", Vector3(0, -0.3, 0), 0.2).as_relative()
	tween.tween_property(pivot_point, "position", Vector3(0, 0.3, 0), 0.2).as_relative()
	var instance = deployable.instantiate()
	instance.position = pivot_point.global_position
	var tree = (Engine.get_main_loop() as SceneTree)
	tree.current_scene.add_child(instance)

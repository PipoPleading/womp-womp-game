extends ToolData
class_name EasterEgg

#TODO: Replace deployable model with player model
var deployable = preload("res://dev folders/chris/Tools/easter_egg_deployable.tscn")

func attack(pivot_point: Node3D, tween: Tween) -> void:
	tween.tween_property(pivot_point, "position", Vector3(0, -1, 0), 0.2).as_relative()
	
	#TODO: Add cloud particles
	tween.tween_callback(func(): 
		var instance = deployable.instantiate()
		instance.position = pivot_point.global_position 
		var tree = (Engine.get_main_loop() as SceneTree)
		tree.current_scene.add_child(instance)
	)

	tween.tween_property(pivot_point, "position", Vector3(0, 1, 0), 0.2).as_relative()

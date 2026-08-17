@tool
extends EditorScript

const ROOT = "res://dev folders/cat/models/Food_and_Kitchen"

var mat: Material

func _run():
	process_directory(ROOT)
	print("Collider Assignment Finished")
	
	
func process_directory(path: String):
	var dir = DirAccess.open(path)
	if dir == null:
		return
	
	dir.list_dir_begin()
	var name = dir.get_next()
	
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
			
		var full = path.path_join(name)
		
		if dir.current_is_dir():
			process_directory(full)
		elif name.ends_with(".tscn"):
			process_scene(full)
			
		name = dir.get_next()
		
	dir.list_dir_end()
	

func process_scene(scene_path: String):
	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("Couldn't load" + scene_path)
		return
	
	var root = packed.instantiate()
	
	apply_collider(root)
	
	var new_scene := PackedScene.new()
	new_scene.pack(root)
	
	var err = ResourceSaver.save(new_scene, scene_path)
	
	if err != OK:
		push_error("Couldn't save " + scene_path)
	else:
		print("Saved ", scene_path)
	

func apply_collider(node: Node):
	if node is MeshInstance3D:
		print("Assigning collider to ", node.name)
		node.create_trimesh_collision()
	
	for child in node.get_children():
		apply_collider(child)

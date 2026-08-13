@tool
extends EditorScript

const ROOT = "res://dev folders/cat/models/Food_and_Kitchen/fbx"
const OUTPUT_ROOT = "res://dev folders/cat/models/Food_and_Kitchen/Scenes"

const scale = 0.4

func _run():
	print("Converting from .fbx to .tscn")
	process_directory(ROOT)
	print("Conversion Finished")
	
	
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
		elif name.ends_with(".fbx"):
			convert_fbx(full)
			
		name = dir.get_next()
		
	dir.list_dir_end()
	

func convert_fbx(fbx_path: String):
	var packed: PackedScene = load(fbx_path)
	if packed == null:
		push_error("Couldn't load" + fbx_path)
		return
	
	var root = packed.instantiate()
	root.scale = Vector3(scale, scale, scale)
	apply_collider(root)
	
	var new_scene := PackedScene.new()
	new_scene.pack(root)
	
	var relative = fbx_path.trim_prefix(ROOT + "/")
	var out = OUTPUT_ROOT.path_join(relative.get_basename() + ".tscn")
	
	DirAccess.make_dir_recursive_absolute(out.get_base_dir())
	var err = ResourceSaver.save(new_scene, out)
	
	if err != OK:
		push_error("Couldn't save " + out)
	else:
		print("Saved ", out)


func apply_collider(node: Node):
	if node is MeshInstance3D:
		print("Assigning collider to ", node.name)
		node.create_trimesh_collision()
	
	for child in node.get_children():
		apply_collider(child)

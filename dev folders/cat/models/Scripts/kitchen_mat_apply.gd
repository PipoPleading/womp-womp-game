@tool
extends EditorScript

const ROOT = "res://dev folders/cat/models/kitchen/Assets"
const OUTPUT_ROOT = "res://dev folders/cat/models/kitchen/Scenes"
const MATERIAL := "res://dev folders/cat/models/kitchen/Texture/kitchen_mat.tres"

var mat: Material

func _run():
	mat = load(MATERIAL)
	process_directory(ROOT)
	print("Material Replace Finished")
	
	
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
		elif name.ends_with(".tcsn"):
			var err = DirAccess.remove_absolute(full)
			if err != OK:
				push_error("Failed to delete: " + full)
			
		name = dir.get_next()
		
	dir.list_dir_end()
	

func convert_fbx(fbx_path: String):
	var packed: PackedScene = load(fbx_path)
	if packed == null:
		push_error("Couldn't load" + fbx_path)
		return
	
	var root = packed.instantiate()
	
	apply_material(root)
	
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
	

func apply_material(node: Node):
	if node is GeometryInstance3D:
		print("Assigning material to ", node.name)
		node.material_override = mat
	
	for child in node.get_children():
		apply_material(child)

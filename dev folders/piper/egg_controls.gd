class_name EggVisual
extends Node3D
# reference for animations
@onready var anims: AnimationPlayer = $AnimationPlayer
## reference for materials
enum anim_state {idle = 0, crouch_jump = 1, crouch_land = 2, crouch_walk = 3, fall = 5, flinch = 6, hurt = 7, idle_crouch = 9, jump = 10, land = 11, walk = 12}
var active_state : int
@onready var egg: MeshInstance3D = $Armature/Skeleton3D/Egg
#@export var shader_param : float: set=get_shader
@export var shader_param : float : set=set_shader_param
const REFRACTIVE = preload("uid://bgoeergysfaib")
var personal_refractive
var mat1
var mat2


func _ready() -> void:
	mat1 = egg.get_surface_override_material(0).duplicate_deep()
	egg.set_surface_override_material(0, mat1)
	mat2 = egg.get_surface_override_material(1).duplicate_deep()
	egg.set_surface_override_material(1, mat2)


func play_anim(current_state : int):
	if active_state != current_state:
		active_state = current_state
	else:
		return
	match current_state:
		anim_state.idle:
			anims.play("Idle")
		anim_state.crouch_jump:
			anims.play("Crouch_Jump")
		anim_state.crouch_land:
			anims.play("Crouch_Land")
		anim_state.crouch_walk:
			anims.play("Crouch_Walk")
		anim_state.fall:
			anims.play("Fall")
		anim_state.flinch:
			anims.play("Flinch")
		anim_state.hurt:
			anims.play("Hurt")
		anim_state.idle_crouch:
			anims.play("Idle_Crouch")
		anim_state.land:
			anims.play("Land")
		anim_state.walk:
			anims.play("Walk")

func set_shader_param(p : float) -> void:
	mat1 = egg.get_surface_override_material(0)
	mat2 = egg.get_surface_override_material(1)
	
	mat1.set_shader_parameter("refraction_str", p)
	mat2.set_shader_parameter("refraction_str", p)
#
#func get_shader_param() -> float:
	#var mat1 = egg.get_surface_override_material(0)
	#var mat2 = egg.get_surface_override_material(1)
	#
	#mat1.get_shader_parameter("refraction_str", shader_param)
	#mat2.set_shader_parameter("refraction_str", shader_param)


func shader_scale(scalar : float):
	shader_param = scalar
	#shader_parameter/refraction_str
	set_shader_param(scalar)
	#print(egg.get_instance_shader_parameter("refraction_str"))
	## scale

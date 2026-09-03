class_name EggVisual
extends Node3D
# reference for animations
@onready var anims: AnimationPlayer = $AnimationPlayer
## reference for materials
enum anim_state {idle = 0, crouch_jump = 1, crouch_land = 2, crouch_walk = 3, fall = 5, flinch = 6, hurt = 7, idle_crouch = 9, jump = 10, land = 11, walk = 12}
var active_state : int
@onready var egg: MeshInstance3D = $Armature/Skeleton3D/Egg

const REFRACTIVE = preload("uid://bgoeergysfaib")
var personal_refractive
@export var mat1 : Material
@export var mat2 : Material


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

func shader_scale(scalar : float):
	set_shader_param(scalar)

func set_shader_param(p : float) -> void:
	mat1 = egg.get_surface_override_material(0)
	mat2 = egg.get_surface_override_material(1)
	
	mat1.set_shader_parameter("refraction_str", p)
	mat2.set_shader_parameter("refraction_str", p)

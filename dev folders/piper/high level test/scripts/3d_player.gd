class_name PlayerInstance extends CharacterBody3D

## everything needs to be loosely coupled
# momentum based movement would be really nice, so having active accelarations instead of flat impulses
# players are going to need to check for fall distance
# players are going to need misc timers for things like stepped_yolk or dripping_yolk seperately
# no sound when crouched, louder sound when sprinting, medium sound when walking
# equipped items and a default off hand no matter what will be relevant
# players should have a death and alive state to differentiate from spectating and playing or menuing
@onready var phantom_camera_3d: PhantomCamera3D = %PhantomCamera3D
@onready var neck_target: Node3D = $NeckRoot/Neck_Target
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

#@onready var eye_1: MeshInstance3D = $Eye1
#@onready var eye_2: MeshInstance3D = $Eye2

@export var _weapon_instance : Node3D 
@onready var frying_pan: Node3D = $FryingPan
@onready var knife: Node3D = $FryingPan2

@export var weapon : WeaponData

enum anim_state {idle = 0, crouch_jump = 1, crouch_land = 2, crouch_walk = 3, fall = 5, flinch = 6, hurt = 7, idle_crouch = 9, jump = 10, land = 11, walk = 12}
var active_state : anim_state

## misc variables to update visuals
var is_falling : bool = false
var is_crouching : bool = false
var is_paused : bool = false

const SPEED = 9.0
const JUMP_VELOCITY = 7
const GRAV_SCALE = 1.2

# Health Stuffs
var current_health : int = 3
var current_weapon : int = 0

const look_sensitivity : float = 0.003

## visuals
@onready var egg_2: EggVisual = $Egg2
@export var visibility_scalar : float = 1.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	_weapon_instance = Node3D.new()
	frying_pan.hide()
	knife.hide()
	GameManager.new_living_player(self)
	if is_multiplayer_authority():
		focus_toggle(true)
		#phantom_camera_3d.priority = 10
		#eye_1.hide()
		#eye_2.hide()
	
	egg_2.play_anim(EggVisual.anim_state.idle)
	#equip_weapon()

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	## rotations for heads
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		## clamp rotation between -90, 90
		neck_target.rotate_x(-event.relative.y * look_sensitivity)
		neck_target.rotation.x = clampf(neck_target.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			focus_toggle(false)
		else:
			focus_toggle(true)
	
	if event.is_action_pressed("cycle_right"):
		change_weapon(1)
	if event.is_action_pressed("cycle_left"):
		change_weapon(-1)
	
	if event.is_action_pressed("attack") and current_weapon > 0:
		if _weapon_instance:
			_weapon_instance.get_node("Weapon").attack()
	

func change_weapon(dir : int):
	if dir > 0:
		current_weapon += 1
	else:
		current_weapon -= 1
	#
	if current_weapon >= 3:
		current_weapon = 0
	if current_weapon < 0:
		current_weapon = 2
	
	match current_weapon:
		0:
			_weapon_instance = Node3D.new()
			frying_pan.hide()
			knife.hide()
		1:
			_weapon_instance = frying_pan
			frying_pan.show()
			knife.hide()
			pass
		2:
			_weapon_instance = knife
			knife.show()
			frying_pan.hide()
			pass
	
	pass

# used for determining mouse state
func focus_toggle(is_focused : bool):
	if is_focused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	
	var input_dir : Vector2 = Input.get_vector("m_left", "m_right", "m_up", "m_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if !is_multiplayer_authority():
		return
	
	
	if direction:
		visibility_scalar = move_toward(visibility_scalar, 0, delta)
	else:
		visibility_scalar = move_toward(visibility_scalar, 1, delta)
	
	egg_2.shader_scale(visibility_scalar)
	

	phantom_camera_3d.priority = 10
	# Add the gravity.
	fall_handling(delta)
	jump_handling()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#if crouchn
		
		update_state(anim_state.walk)
		jump_handling()
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		update_state(anim_state.idle)
		jump_handling()
		
	
	
	move_and_slide()


func crouch_handling():
	if Input.is_action_pressed("crouch"):
		is_crouching = true
	else:
		is_crouching = false
	pass

func fall_handling(delta : float):
	if not is_on_floor():
		velocity += get_gravity() * delta
		## check if velocity.y is negative, if true set fall and is_falling
		if velocity.y < 0 and !is_falling:
			update_state(anim_state.fall)
			is_falling = true

func jump_handling():
	if is_on_floor():
		is_falling = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			update_state(anim_state.jump)

func update_state(target_state : anim_state):
	## send signals here to update animation player on rig
	#current_state = target_state
	egg_2.play_anim(target_state)


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("area : ", area.name)
	if area.is_in_group("Weapon"):
		if area.get_parent().get_parent().get_node("Weapon").is_attacking:
			current_health -= 1
			print("took damage! ", current_health)
		if current_health <= 0:
			print("you dead")
			death()
			#TODO: Make the player transition to Spectator

func death():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.player_died(self)
	phantom_camera_3d.priority = 0
	queue_free()

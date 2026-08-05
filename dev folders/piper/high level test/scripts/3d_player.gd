extends CharacterBody3D

## everything needs to be loosely coupled
# momentum based movement would be really nice, so having active accelarations instead of flat impulses
# players are going to need to check for fall distance
# players are going to need misc timers for things like stepped_yolk or dripping_yolk seperately
# no sound when crouched, louder sound when sprinting, medium sound when walking
# equipped items and a default off hand no matter what will be relevant
# players should have a death and alive state to differentiate from spectating and playing or menuing


enum PLAYER_STATE {idle = 0, idle_crouch = 1, walk = 2, walk_crouch = 3, jump = 4, fall = 5, land = 6, flinch = 7, hurt = 8, dead = 9, spectating = 10}
var current_state = PLAYER_STATE.idle

## misc variables to update visuals
var is_falling : bool = false
var is_crouching : bool = false

@onready var phantom_camera_3d: PhantomCamera3D = %PhantomCamera3D

@onready var neck_target: Node3D = $NeckRoot/Neck_Target

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const look_sensitivity : float = 0.003

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		focus_toggle(true)

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	## rotations for heads
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		neck_target.rotate_x(-event.relative.y * look_sensitivity)
	
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			focus_toggle(false)
		else:
			focus_toggle(true)
	pass

# used for determining mouse state
func focus_toggle(is_focused : bool):
	if is_focused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	phantom_camera_3d.priority = 10
	
	# Add the gravity.

	fall_handling(delta)
	jump_handling()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector2 = Input.get_vector("m_left", "m_right", "m_up", "m_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		## crouch check here
		update_state(PLAYER_STATE.walk)
		jump_handling()
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		## crouch check here
		update_state(PLAYER_STATE.idle)
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
			update_state(PLAYER_STATE.fall)
			is_falling = true

func jump_handling():
	if is_on_floor():
		is_falling = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			update_state(PLAYER_STATE.jump)

func update_state(target_state : PLAYER_STATE):
	## send signals here to update animation player on rig
	current_state = target_state

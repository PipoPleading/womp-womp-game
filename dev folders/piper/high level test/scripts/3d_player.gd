extends CharacterBody3D

## everything needs to be loosely coupled
# momentum based movement would be really nice, so having active accelarations instead of flat impulses
# players are going to need to check for fall distance
# players are going to need misc timers for things like stepped_yolk or dripping_yolk seperately
# no sound when crouched, louder sound when sprinting, medium sound when walking
# equipped items and a default off hand no matter what will be relevant
# players should have a death and alive state to differentiate from spectating and playing or menuing


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("m_left", "m_right", "m_up", "m_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

extends CharacterBody3D

const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5


const TEST_WEAPON = preload("res://dev folders/chris/Weapons/frying_pan.tscn")
var weapon_instance : Node3D
var t : float = 0

var attack_rotation : Vector3
var is_attacking = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("ui_attack"):
		weapon_instance.get_node("Weapon").attack()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func equip_weapon() -> void:
	weapon_instance = TEST_WEAPON.instantiate()
	add_child(weapon_instance)
	weapon_instance.position = Vector3(1,0.5,0)
	

func _ready() -> void:
	equip_weapon()

func attack_lerp(lerp_speed: float) -> void:
	t += 0.1
	weapon_instance.rotation_degrees = lerp(weapon_instance.rotation_degrees, attack_rotation, t * lerp_speed)

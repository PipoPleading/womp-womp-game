extends CharacterBody3D

# Movement Settings
const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5

# Weapon Settings
var _weapon_instance : Node3D
@export var weapon : WeaponData

func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
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

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
	if Input.is_action_just_pressed("attack"):
		_weapon_instance.get_node("Weapon").attack()

func equip_weapon() -> void:
	_weapon_instance = load(weapon.weapon_location).instantiate()
	add_child(_weapon_instance)
	_weapon_instance.position = weapon.initial_position
	

func _ready() -> void:
	equip_weapon()

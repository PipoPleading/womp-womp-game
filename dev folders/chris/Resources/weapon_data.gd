extends Resource
class_name WeaponData

enum WeaponType {Melee, Projectile}

@export var name : String
@export var type : WeaponType
@export var damage : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

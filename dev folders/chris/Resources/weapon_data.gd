extends Resource
class_name WeaponData

enum WeaponType {Melee, Projectile}

@export var name : String
@export var type : WeaponType
@export var damage : int
@export var weapon_location : String

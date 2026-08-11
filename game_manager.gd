extends Node

var timer : Timer
@export var game_start_time : float


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

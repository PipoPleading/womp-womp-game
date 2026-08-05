extends Node

@export var explosion_time : float = 2
@export var timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = explosion_time
	timer.start()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	queue_free()

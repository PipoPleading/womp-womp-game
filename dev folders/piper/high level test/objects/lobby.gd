extends Node3D

const _3D_PLAYER = preload("uid://cwiwagkfn8cmc")

var players : Array[CharacterBody3D]
@export var spawn_points : Array[Node3D]

func _ready() -> void:
	Networking.host_created.connect(on_host_created)

func on_host_created() -> void:
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)


func spawn_player(peer_id: int) -> void:
	var new_player := _3D_PLAYER.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)
	initialize_player(new_player)

func initialize_player(player : CharacterBody3D) -> void:
	player.position = spawn_points[0].position
	for other in players:
		player.add_collision_exception_with(other)
	players.append(player)

func on_host_pressed() -> void:
	Networking.host_lobby()

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is CharacterBody3D:
		initialize_player(node)

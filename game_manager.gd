extends Node

#
var round_timer : Timer

#Making it clear how long in minutes a round lasts
var game_time : float = 60 * 5

#This would get emitted to each player 
#and the player will connect the positions to their local minimap
signal update_minimap_positions(enemy_positions : Array[Vector3])

#This would be for starting the game (i.e when the lobby starts)
signal start_game()

#This would be used for emitting when the game ends as well as
#if that player was the winner
signal finish_game(is_winning_player : bool)

signal dead(player : PlayerInstance)

var living_players : Array[PlayerInstance]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("force_start"):
		load_game()

func new_living_player(player : PlayerInstance):
	living_players.append(player)

func player_died(player : PlayerInstance):
	if living_players.has(player):
		living_players.remove_at(living_players.find(player))
		print("dead emitting here")
		if is_multiplayer_authority():
			dead.emit(player)
	print("current players: ", living_players)

func _ready() -> void:
	start_game.connect(load_game)
	
	round_timer = Timer.new()
	add_child(round_timer)
	
	round_timer.wait_time = game_time
	round_timer.start()

func load_game():
	get_tree().change_scene_to_file("uid://dhh8s6n07t6id")
	
	pass

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

func player_died():
	pass
#assigning timer and starting it (realistically wouldn't start on ready)
func _ready() -> void:
	round_timer = Timer.new()
	add_child(round_timer)
	
	round_timer.wait_time = game_time
	round_timer.start()

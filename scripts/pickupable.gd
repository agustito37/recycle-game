extends StaticBody2D

enum State { FREE, CARRIED }
var current_state = State.FREE
var carrying_player = null
var original_z_index = 0

func be_picked_up(player):
	if current_state == State.FREE:
		current_state = State.CARRIED
		carrying_player = player
		collision_layer = 0
		original_z_index = z_index
		z_index = 10

func be_released():
	if current_state == State.CARRIED:
		current_state = State.FREE
		carrying_player = null
		collision_layer = 1
		z_index = original_z_index

func is_free() -> bool:
	return current_state == State.FREE

func is_carried() -> bool:
	return current_state == State.CARRIED

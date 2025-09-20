class_name PickupableComponent
extends Node

signal picked_up(player)
signal released()

enum State { FREE, CARRIED }
var state = State.FREE

func be_picked_up(player):
	if state == State.FREE:
		state = State.CARRIED
		picked_up.emit(player)

func be_released():
	if state == State.CARRIED:
		state = State.FREE
		released.emit()

func is_free() -> bool:
	return state == State.FREE

func is_carried() -> bool:
	return state == State.CARRIED

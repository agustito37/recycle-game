class_name MovementComponent
extends Node

signal direction_changed(new_direction: Vector2)
signal movement_state_changed(is_moving: bool, direction: Vector2)

@export var move_speed: float = 100.0
@export var starting_direction: Vector2 = Vector2(0, 1)

var current_direction: Vector2 = Vector2(0, 1)
var velocity: Vector2 = Vector2.ZERO
var was_moving: bool = false

var character_body: CharacterBody2D

func _ready():
	character_body = get_parent() as CharacterBody2D
	if not character_body:
		push_error("MovementComponent must be child of CharacterBody2D")
		return

	current_direction = starting_direction

func _physics_process(_delta):
	if not character_body:
		return

	_handle_input()
	_apply_movement()

func _handle_input():
	var input_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		var old_direction = current_direction
		current_direction = input_direction

		if old_direction != current_direction:
			direction_changed.emit(current_direction)

	velocity = input_direction * move_speed

	# Check for movement state changes
	var is_moving_now = velocity.length() > 0
	if is_moving_now != was_moving:
		was_moving = is_moving_now
		movement_state_changed.emit(is_moving_now, current_direction)

func _apply_movement():
	character_body.velocity = velocity
	character_body.move_and_slide()

func get_current_direction() -> Vector2:
	return current_direction

func is_moving() -> bool:
	return velocity.length() > 0

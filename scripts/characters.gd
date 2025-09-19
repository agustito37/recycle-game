extends CharacterBody2D

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, 1)
@export var pickup_range : float = 70.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var carried_item = null
var current_direction = Vector2(0, 1)

func _ready():
	current_direction = starting_direction
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
		current_direction = input_direction

	update_animation_parameters(input_direction)

	handle_pickup_input()

	velocity = input_direction * move_speed

	move_and_slide()

	pick_new_state()

	update_carried_item()

func update_animation_parameters(move_input  : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Run/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Run")
	else:
		state_machine.travel("Idle")

func handle_pickup_input():
	if Input.is_action_just_pressed("ui_accept"):
		if carried_item == null:
			try_pickup_item()
		else:
			release_item()

func try_pickup_item():
	var item = find_nearby_pickupable()
	if item and item.is_free():
		# Calcular dirección del player hacia el item para posicionamiento
		var direction_to_item = (item.global_position - global_position).normalized()
		current_direction = direction_to_item
		carried_item = item
		item.be_picked_up(self)

func release_item():
	if carried_item:
		carried_item.be_released()
		carried_item = null

func find_nearby_pickupable():
	var pickupables = get_tree().get_nodes_in_group("pickupables")
	for item in pickupables:
		var distance = global_position.distance_to(item.global_position)
		if distance <= pickup_range:
			return item
	return null

func update_carried_item():
	if carried_item:
		var offset = current_direction * 30
		var target_position = global_position + offset
		carried_item.global_position = target_position
  

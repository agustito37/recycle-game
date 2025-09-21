extends StaticBody2D

@onready var pickupable_component: PickupableComponent = $PickupableComponent
@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	add_to_group("pickupables")

	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact")
		_update_interaction_text()

func _physics_process(_delta):
	if pickupable_component.is_carried():
		_update_carry_position()

func _on_interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var carrier = player.get_node("ItemCarrierComponent") as ItemCarrierComponent
	if not carrier:
		return

	if pickupable_component.is_free() and not carrier.has_item():
		_be_picked_up(player, carrier)
	elif pickupable_component.is_carried() and carrier.get_carried_item() == self:
		_be_dropped(carrier)

func _be_picked_up(player, carrier):
	# Disable physics and visual changes
	collision_layer = 0
	z_index = 10

	# Update carrier and component state
	carrier.set_carried_item(self)
	pickupable_component.be_picked_up(player)

	# Update position to follow player
	_start_following_player(player)

	# Update interaction text
	_update_interaction_text()

func _be_dropped(carrier):
	# Re-enable physics and restore visual
	collision_layer = 1
	z_index = 0

	# Position with collision detection
	_position_item_near_player(carrier.get_parent())

	# Update carrier and component state
	carrier.clear_carried_item()
	pickupable_component.be_released()

	# Update interaction text
	_update_interaction_text()

func _start_following_player(player):
	# Connect to movement to follow player
	var movement = player.get_node("MovementComponent")
	if movement and not movement.direction_changed.is_connected(_on_player_direction_changed):
		movement.direction_changed.connect(_on_player_direction_changed)

func _update_carry_position():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = player.get_current_direction()
		global_position = player.global_position + (direction * 30)

func _on_player_direction_changed(direction: Vector2):
	# This is just for direction changes, main positioning is handled in _physics_process
	pass

func _position_item_near_player(player):
	var space_state = player.get_world_2d().direct_space_state

	# Get current player direction and calculate relative directions
	var player_direction = player.get_current_direction()

	# Calculate relative directions: forward, right, left, back
	var forward = player_direction
	var right = Vector2(-player_direction.y, player_direction.x)   # Perpendicular clockwise
	var left = Vector2(player_direction.y, -player_direction.x)   # Perpendicular counter-clockwise
	var back = -player_direction

	# Priority: adelante, derecha, izquierda, atrás (relative to player direction)
	var directions = [forward, right, left, back]
	var tile_size = 48

	for direction in directions:
		var test_position = player.global_position + (direction * tile_size)

		# Check if position is free
		var query = PhysicsPointQueryParameters2D.new()
		query.position = test_position
		query.collision_mask = 1  # Check static bodies

		var result = space_state.intersect_point(query)
		if result.is_empty():
			global_position = test_position
			return

	# Fallback: place at player position if no free space found
	global_position = player.global_position

func _update_interaction_text():
	if not interaction_area:
		return

	if pickupable_component.is_carried():
		interaction_area.action_name = "drop"
	else:
		interaction_area.action_name = "pick up"

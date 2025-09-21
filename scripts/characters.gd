extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var item_carrier_component: ItemCarrierComponent = $ItemCarrierComponent

var nearby_pickables: Array = []
var nearby_receivers: Array = []


func _ready():
	add_to_group("player")
	_setup_components()

func _setup_components():
	# Wait for components to be ready
	await get_tree().process_frame

	# Setup animation component with movement component
	if animation_component and movement_component:
		movement_component.direction_changed.connect(_on_direction_changed)
		movement_component.movement_state_changed.connect(_on_movement_state_changed)

func _on_direction_changed(direction: Vector2):
	if animation_component:
		animation_component.set_parameter("Idle/blend_position", direction)
		animation_component.set_parameter("Run/blend_position", direction)

func _on_movement_state_changed(is_moving: bool, direction: Vector2):
	if animation_component:
		if is_moving:
			animation_component.play("Run")
		else:
			animation_component.play("Idle")

		animation_component.set_parameter("Idle/blend_position", direction)
		animation_component.set_parameter("Run/blend_position", direction)

# Compatibility methods - direct delegation to components
func get_current_direction() -> Vector2:
	if movement_component:
		return movement_component.get_current_direction()
	return Vector2(0, 1)

func get_carried_item():
	if item_carrier_component:
		return item_carrier_component.get_carried_item()
	return null

func _physics_process(_delta):
	_update_interactions()

func _update_interactions():
	# Use the existing InteractionManager system but control it from character
	var has_item = item_carrier_component.has_item()

	# Find nearby receivers and pickables using InteractionManager's current areas
	var active_receivers = []
	var active_pickables = []

	for area in InteractionManager.active_areas:
		var parent = area.get_parent()
		if parent.has_node("ItemProcessorComponent"):
			var processor = parent.get_node("ItemProcessorComponent")
			# If processor is ready, treat as pickable, otherwise as receiver
			if processor.is_ready():
				active_pickables.append(area)
			else:
				active_receivers.append(area)
		elif parent.is_in_group("pickupables"):
			active_pickables.append(area)

	# Clear all current areas
	InteractionManager.active_areas.clear()

	# Apply simple conditions
	# Condition 1: Have item + receiver nearby → cook
	if has_item and active_receivers.size() > 0:
		InteractionManager.active_areas.append(active_receivers[0])

	# Condition 2: No item + pickable nearby → pick up
	elif not has_item and active_pickables.size() > 0:
		InteractionManager.active_areas.append(active_pickables[0])

	# Condition 3: Have item + no receiver nearby → drop
	elif has_item:
		var carried_item = item_carrier_component.get_carried_item()
		if carried_item and carried_item.has_node("InteractionArea"):
			InteractionManager.active_areas.append(carried_item.get_node("InteractionArea"))

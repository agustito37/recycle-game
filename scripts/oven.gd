extends StaticBody2D

@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var processor: ItemProcessorComponent = $ItemProcessorComponent
@onready var interaction_area: InteractionArea = $InteractionArea

const COOKING_TIME = 5.0

func _ready():
	add_to_group("item_receivers")

	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact")
		_update_interaction_text()

	if processor:
		processor.processing_finished.connect(_on_processing_finished)

func _on_interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var carrier = player.get_node("ItemCarrierComponent") as ItemCarrierComponent
	if not carrier:
		return

	# If player has item and we can accept it
	if carrier.has_item() and _can_accept_item(carrier.get_carried_item()):
		var item = carrier.get_carried_item()
		carrier.clear_carried_item()
		_receive_item(item)

	# If we have finished item, give it to player
	elif processor.is_ready():
		if not carrier.has_item():
			var item = processor.remove_item()
			if item:
				carrier.set_carried_item(item)

				# Re-enable item interactions after processing
				if item.has_node("InteractionArea"):
					var interaction_area = item.get_node("InteractionArea")
					interaction_area.set_monitoring(true)
					interaction_area.set_monitorable(true)

				# Set pickupable state if item has pickupable component
				if item.has_node("PickupableComponent"):
					var pickupable_comp = item.get_node("PickupableComponent")
					pickupable_comp.be_picked_up(player)

				# Update interaction text for the item being picked up
				if item.has_method("_update_interaction_text"):
					item._update_interaction_text()

				# Update oven interaction text after item removal
				_update_interaction_text()

func _can_accept_item(item) -> bool:
	# Simplified check - if item exists and we have space and not processing
	if not item:
		return false
	if not processor.has_space():
		return false
	if processor.is_currently_processing():
		return false
	# Accept any pickupable item
	return item.is_in_group("pickupables")

func _receive_item(item):
	# Position item at oven fire level (lower and smaller) and disable physics
	item.global_position = global_position
	item.global_position.y += 20  # Position lower in the fire area
	if "collision_layer" in item:
		item.collision_layer = 0

	# Make item smaller during cooking
	if "scale" in item:
		item.scale = Vector2(0.7, 0.7)  # 70% of original size

	# Release pickupable state if item has pickupable component
	if item.has_node("PickupableComponent"):
		var pickupable_comp = item.get_node("PickupableComponent")
		pickupable_comp.be_released()

	# Disable item interactions during processing
	if item.has_node("InteractionArea"):
		var interaction_area = item.get_node("InteractionArea")
		interaction_area.set_monitoring(false)
		interaction_area.set_monitorable(false)

	# Store item and start cooking
	processor.add_item_and_start_processing(item, COOKING_TIME)
	animation_component.play("cooking")

	# Disable oven interactions during processing
	if interaction_area:
		interaction_area.set_monitoring(false)
		interaction_area.set_monitorable(false)

func _on_processing_finished():
	# Apply cooking effect to item
	var items = processor.get_items()
	if items.size() > 0:
		var item = items[0]
		if "modulate" in item:
			item.modulate = Color(0.6, 0.4, 0.2)  # Brown color

		# Restore original size
		if "scale" in item:
			item.scale = Vector2(1.0, 1.0)  # Restore to original size

	animation_component.play("idle")

	# Re-enable oven interactions after processing
	if interaction_area:
		interaction_area.set_monitoring(true)
		interaction_area.set_monitorable(true)

	_update_interaction_text()


func _update_interaction_text():
	if not interaction_area:
		return

	match processor.state:
		ItemProcessorComponent.State.EMPTY:
			interaction_area.action_name = "cook"
		ItemProcessorComponent.State.READY:
			interaction_area.action_name = "pick up"
		# PROCESSING state is handled by disabling interactions completely

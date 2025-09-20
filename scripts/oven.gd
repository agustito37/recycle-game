extends StaticBody2D

@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var item_receiver_component: ItemReceiverComponent = $ItemReceiverComponent
@onready var item_processor_component: ItemProcessorComponent = $ItemProcessorComponent
@onready var interaction_area: InteractionArea = $InteractionArea

const COOKING_TIME = 5.0

func _ready():
	add_to_group("item_receivers")

	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact")
		_update_interaction_text()

	if item_processor_component:
		item_processor_component.processing_finished.connect(_on_processing_finished)

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
	elif item_receiver_component.has_items() and not item_processor_component.is_processing:
		if not carrier.has_item():
			var item = item_receiver_component.remove_item(item_receiver_component.get_items()[0])
			carrier.set_carried_item(item)

			# Set pickupable state if item has pickupable component
			if item.has_node("PickupableComponent"):
				var pickupable_comp = item.get_node("PickupableComponent")
				pickupable_comp.be_picked_up(player)

			_update_interaction_text()

func _can_accept_item(item) -> bool:
	# Simplified check - if item exists and we have space and not processing
	if not item:
		return false
	if not item_receiver_component.has_space():
		return false
	if item_processor_component.is_processing:
		return false
	# Accept any pickupable item
	return item.is_in_group("pickupables")

func _receive_item(item):
	# Position item at oven and disable physics
	item.global_position = global_position
	if "collision_layer" in item:
		item.collision_layer = 0

	# Release pickupable state if item has pickupable component
	if item.has_node("PickupableComponent"):
		var pickupable_comp = item.get_node("PickupableComponent")
		pickupable_comp.be_released()

	# Store item and start cooking
	item_receiver_component.add_item(item)
	item_processor_component.start_processing(COOKING_TIME)
	animation_component.play("cooking")
	_update_interaction_text()

func _on_processing_finished():
	# Apply cooking effect to item
	var items = item_receiver_component.get_items()
	if items.size() > 0:
		var item = items[0]
		if "modulate" in item:
			item.modulate = Color(0.6, 0.4, 0.2)  # Brown color

	animation_component.play("idle")
	_update_interaction_text()


func _update_interaction_text():
	if not interaction_area:
		return

	if item_receiver_component.has_items():
		if item_processor_component.is_processing:
			interaction_area.action_name = "cooking..."
		else:
			interaction_area.action_name = "pick up"
	else:
		interaction_area.action_name = "cook"

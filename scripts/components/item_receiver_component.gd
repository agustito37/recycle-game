class_name ItemReceiverComponent
extends Node

signal item_received(item)
signal item_extracted(item)

var items: Array = []

func add_item(item):
	if item and not items.has(item):
		items.append(item)
		item_received.emit(item)

func remove_item(item):
	var index = items.find(item)
	if index != -1:
		items.remove_at(index)
		item_extracted.emit(item)
		return item
	return null

func get_items() -> Array:
	return items.duplicate()

func has_items() -> bool:
	return not items.is_empty()

func has_space() -> bool:
	return true  # Unlimited by default, parent object decides limits

func clear_all_items():
	var removed_items = items.duplicate()
	items.clear()
	for item in removed_items:
		item_extracted.emit(item)
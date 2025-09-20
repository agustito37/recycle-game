class_name ItemCarrierComponent
extends Node

signal item_picked_up(item)
signal item_dropped(item)

var carried_item = null

func set_carried_item(item):
	if carried_item != item:
		var old_item = carried_item
		carried_item = item

		if old_item:
			item_dropped.emit(old_item)
		if item:
			item_picked_up.emit(item)

func get_carried_item():
	return carried_item

func has_item() -> bool:
	return carried_item != null

func clear_carried_item():
	if carried_item:
		var item = carried_item
		carried_item = null
		item_dropped.emit(item)

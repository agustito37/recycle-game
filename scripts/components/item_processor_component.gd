class_name ItemProcessorComponent
extends Node

# Processing signals
signal processing_finished()

# Item receiver signals
signal item_received(item)
signal item_extracted(item)

# State management
enum State { EMPTY, PROCESSING, READY }
var state = State.EMPTY

# Processing variables
var processing_timer: float = 0.0
var processing_duration: float = 0.0

# Item storage
var items: Array = []

# Item management methods
func add_item(item):
	if item and not items.has(item):
		items.append(item)
		item_received.emit(item)

func remove_item(item = null):
	var target_item = item if item else (items[0] if items.size() > 0 else null)
	if target_item:
		var index = items.find(target_item)
		if index != -1:
			items.remove_at(index)
			item_extracted.emit(target_item)
			if items.is_empty():
				reset()
			return target_item
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
	reset()

# State management methods
func is_empty() -> bool:
	return state == State.EMPTY

func is_currently_processing() -> bool:
	return state == State.PROCESSING

func is_ready() -> bool:
	return state == State.READY

func reset():
	state = State.EMPTY
	stop_processing()

# Processing methods
func _physics_process(delta):
	if state == State.PROCESSING:
		processing_timer += delta
		if processing_timer >= processing_duration:
			_finish_processing()

func start_processing(duration: float):
	if state == State.PROCESSING:
		return false

	processing_duration = duration
	processing_timer = 0.0
	state = State.PROCESSING
	return true

func add_item_and_start_processing(item, duration: float):
	add_item(item)
	start_processing(duration)

func update_processing(delta: float) -> bool:
	if state != State.PROCESSING:
		return false

	processing_timer += delta
	if processing_timer >= processing_duration:
		_finish_processing()
		return true
	return false

func stop_processing():
	if state == State.PROCESSING:
		state = State.EMPTY
	processing_timer = 0.0

func _finish_processing():
	state = State.READY
	processing_timer = 0.0
	processing_finished.emit()

func get_progress() -> float:
	if state != State.PROCESSING or processing_duration <= 0:
		return 0.0
	return processing_timer / processing_duration
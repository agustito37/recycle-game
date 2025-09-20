class_name ItemProcessorComponent
extends Node

signal processing_finished()

var processing_timer: float = 0.0
var is_processing: bool = false
var processing_duration: float = 0.0

func _physics_process(delta):
	if is_processing:
		processing_timer += delta
		if processing_timer >= processing_duration:
			_finish_processing()

func start_processing(duration: float):
	if is_processing:
		return false

	processing_duration = duration
	processing_timer = 0.0
	is_processing = true
	return true

func update_processing(delta: float) -> bool:
	if not is_processing:
		return false

	processing_timer += delta
	if processing_timer >= processing_duration:
		_finish_processing()
		return true
	return false

func stop_processing():
	is_processing = false
	processing_timer = 0.0

func _finish_processing():
	is_processing = false
	processing_timer = 0.0
	processing_finished.emit()

func get_progress() -> float:
	if not is_processing or processing_duration <= 0:
		return 0.0
	return processing_timer / processing_duration
class_name InteractionArea
extends Area2D

@export var action_name: String = "interact"

var interact: Callable = func(): pass

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Enable area detection for area-to-area interaction
	set_monitoring(true)
	set_monitorable(true)

func _on_body_entered(body):
	InteractionManager.register_area(self)

func _on_body_exited(body):
	InteractionManager.unregister_area(self)
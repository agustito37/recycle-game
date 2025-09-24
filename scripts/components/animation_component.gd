class_name AnimationComponent
extends Node

@export var animation_tree_path: NodePath = NodePath("../AnimationTree")

var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback

func _ready():
	await get_parent().ready
	_setup_animation_tree()

func _setup_animation_tree():
	animation_tree = get_node(animation_tree_path) as AnimationTree
	if not animation_tree:
		push_error("AnimationComponent: AnimationTree not found at path: " + str(animation_tree_path))
		return

	state_machine = animation_tree.get("parameters/playback")
	if not state_machine:
		push_error("AnimationComponent: StateMachine playback not found")

func play(animation_name: String):
	if state_machine:
		state_machine.travel(animation_name)

func set_parameter(parameter_path: String, value):
	if animation_tree:
		animation_tree.set("parameters/" + parameter_path, value)

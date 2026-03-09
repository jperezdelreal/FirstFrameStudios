## Generic node-based state machine controller.
## Each child Node is a state. Runs the active state's physics_update
## every physics tick for deterministic, frame-perfect behavior.
class_name StateMachine
extends Node

signal state_changed(new_state_name: String)

@export var initial_state: Node

var current_state: Node
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is Node:
			states[child.name.to_lower()] = child
			child.state_machine = self
	if initial_state:
		current_state = initial_state
		current_state.enter({})

func _physics_process(_delta: float) -> void:
	if current_state:
		current_state.physics_update()

func transition_to(target_state_name: String, args: Dictionary = {}) -> void:
	var target = states.get(target_state_name.to_lower())
	if target == null:
		push_warning("State '%s' not found" % target_state_name)
		return
	if current_state:
		current_state.exit()
	current_state = target
	current_state.enter(args)
	state_changed.emit(target_state_name)

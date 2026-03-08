## Base state class. Every concrete state (idle, walk, attack, etc.)
## extends this and overrides enter/exit/physics_update/handle_input.
## Uses integer frame counters — no float timers — for determinism.
class_name State
extends Node

var state_machine: StateMachine
var frames_in_state: int = 0

func enter(_args: Dictionary) -> void:
	frames_in_state = 0

func exit() -> void:
	pass

func physics_update() -> void:
	frames_in_state += 1

func handle_input(_input_data: Dictionary) -> void:
	pass

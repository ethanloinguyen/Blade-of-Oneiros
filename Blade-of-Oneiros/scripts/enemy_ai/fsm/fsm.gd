# Finite state machine for AI
class_name FSM
extends RefCounted


var current_state:State


func _init(initial_state:State) -> void:
	current_state = initial_state


func update(delta:float):
	if current_state.on_update.is_valid():
		current_state.on_update.call(delta)


func change_state(new_state:State):
	if current_state.on_exit.is_valid():
		current_state.on_exit.call()
	current_state = new_state
	if current_state.on_enter.is_valid():
		current_state.on_enter.call()

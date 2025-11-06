class_name Enemy
extends CharacterBody2D

@export var activate_distance:float

var fsm:FSM

var _player:TestPlayer


func _ready():
	_player = get_tree().get_first_node_in_group("player")

	# create states
	var wait_state:State
	var chase_state:State
	wait_state = State.new(
		"Wait",
		Callable(),
		func(_delta:float):
		if _player.global_position.distance_to(global_position) < activate_distance:
			fsm.change_state(chase_state)
			# TODO temp
			print("LEAVE WAIT STATE")
		,
		Callable(),
	)
	chase_state = State.new(
		"Chase",
		Callable(),
		Callable(),
		Callable(),
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	fsm.update(delta)

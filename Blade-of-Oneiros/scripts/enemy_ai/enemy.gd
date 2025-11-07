class_name Enemy
extends CharacterBody2D

@export var activate_distance:float
@export var speed:float
@export var chase_leash_distance:float

var fsm:FSM
var wait_state:State
var chase_state:State

var _player:TestPlayer


func _ready():
	_player = get_tree().get_first_node_in_group("player")

	# create states
	wait_state = State.new(
		"Wait",
		Callable(),
		func(_delta:float):
		if _player.global_position.distance_to(global_position) < activate_distance:
			fsm.change_state(chase_state)
		,
		Callable(),
	)
	chase_state = State.new(
		"Chase",
		Callable(),
		func(_delta:float):
		if _player.global_position.distance_to(global_position) > chase_leash_distance:
			velocity = (_player.global_position - global_position).normalized() * speed
		else:
			velocity = Vector2(0, 0)
		,
		Callable(),
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	fsm.update(delta)
	move_and_slide()

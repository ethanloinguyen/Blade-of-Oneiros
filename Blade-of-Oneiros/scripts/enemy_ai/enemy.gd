class_name Enemy
extends CharacterBody2D

@onready var player:TestPlayer = $TestPlayer

var fsm:FSM


func _ready():
	var wait_state:State
	wait_state= State.new(
		"Wait",
		Callable(),
		Callable(func(_delta:float):
		if player.global_position.distance_to(global_position):
			print("LEAVE WAIT STATE")
		),
		Callable(),
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	fsm.update(delta)


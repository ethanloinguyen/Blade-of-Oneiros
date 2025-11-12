class_name Enemy
extends CharacterBody2D

@export var activate_distance:float
@export var speed:float
@export var chase_leash_distance:float

@export var attack_hitbox:Hitbox
@export var attack_distance:float

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var fsm:FSM
var wait_state:State
var chase_state:State
var attack_state:State

var _player:Player
var _dir:String = "down"


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
		var dist_to_player:float= _player.global_position.distance_to(global_position)
		if dist_to_player > chase_leash_distance:
			velocity = (_player.global_position - global_position).normalized() * speed
		elif dist_to_player < attack_distance:
			fsm.change_state(attack_state)
		else:
			velocity = Vector2(0, 0)
		,
		Callable(),
	)
	attack_state = State.new(
		"Attack",
		func():
		velocity = Vector2(0, 0)
		attack_hitbox.activate()
		,
		func(_delta:float):
		# TODO: wait for attack animation to finish
		fsm.change_state(chase_state)
		,
		Callable()
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	fsm.update(delta)
	_update_sprite()
	move_and_slide()


func _update_sprite() -> void:
	if velocity.x > velocity.y:
		if velocity.x > 0:
			_dir = "right"
		elif velocity.x < 0:
			_dir = "left"
	else:
		if velocity.y > 0:
			_dir = "down"
		elif velocity.y < 0:
			_dir = "up"

	if velocity.is_zero_approx():
		sprite.play("idle_%s" % [_dir])
	else:
		sprite.play("walk_%s" % [_dir])

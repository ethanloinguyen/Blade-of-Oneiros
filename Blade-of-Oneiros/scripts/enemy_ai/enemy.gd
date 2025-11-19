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
		_play_animation("idle")

		# transition
		if _player.global_position.distance_to(global_position) < activate_distance:
			fsm.change_state(chase_state)
		,
		Callable(),
	)
	chase_state = State.new(
		"Chase",
		Callable(),
		func(_delta:float):
		var dist_to_player:float = _player.global_position.distance_to(global_position)
		if dist_to_player > chase_leash_distance:
			velocity = (_player.global_position - global_position).normalized() * speed
		else:
			velocity = Vector2(0, 0)

		# play animation
		if velocity.is_zero_approx():
			_play_animation("idle")
		else:
			_play_animation("walk")

		# transition
		if dist_to_player < attack_distance:
			fsm.change_state(attack_state)
		,
		Callable(),
	)
	attack_state = State.new(
		"Attack",
		func():
		attack_hitbox.activate(_player.global_position - global_position)
		_play_animation("attack")

		# wait for attack animation to finish
		await sprite.animation_finished
		fsm.change_state(chase_state)
		,
		func(_delta:float):
		velocity = Vector2(0, 0)
		,
		Callable()
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	fsm.update(delta)
	_update_dir()
	move_and_slide()


func _update_dir() -> void:
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


func _play_animation(animation:String) -> void:
	sprite.play("%s_%s" % [animation, _dir])

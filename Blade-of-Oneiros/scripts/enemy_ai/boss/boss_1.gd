class_name Boss_1
extends CharacterBody2D


@onready var attack_hitbox = $JumpHitbox
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var health:Health = $Health

@export var between_states_wait_duration:float = 4.0

@export var projectile:PackedScene

var fsm:FSM
var idle_state:State
var jump_state:JumpState
var shoot_state:ShootState
var attack_state:State
var stun_state:State

var _player:Player
var _dir:String = "down"


func _enter_tree():
	add_to_group("enemy")


func _ready():
	# create states
	idle_state = State.new(
		"Idle",
		func():
		_face_player(),
		func(_delta):
		AiHelper.play_animation(sprite, "idle", _dir)
		,
		Callable(),
	)
	jump_state = JumpState.new(self, 100, 1.0, sprite, attack_hitbox, func():
		_idle(between_states_wait_duration, func():
			fsm.change_state(shoot_state)
		)
	)
	shoot_state = ShootState.new(self, projectile, 4, false, func():
		_idle(between_states_wait_duration, func():
			jump_state.jump(_player.global_position)
		)
	)
	fsm = FSM.new(idle_state)
	jump_state.jump(_player.global_position)


func _physics_process(delta:float) -> void:
	if not health.is_dead():
		fsm.update(delta)
		move_and_slide()


func _face_player():
	var to_player = _player.global_position - global_position
	_dir = AiHelper.update_dir(to_player)


func _idle(duration:float, exit_idle:Callable):
	fsm.change_state(idle_state)
	await get_tree().create_timer(duration).timeout
	exit_idle.call()

class_name Boss_1
extends CharacterBody2D


@onready var attack_hitbox = $JumpHitbox
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var health:Health = $Health

@export var between_states_wait_duration:float = 4.0

@export var projectile:PackedScene

@export var next_boss:PackedScene
@export var slime_enemy:PackedScene
@export var death_slime_spawn_count:int = 3

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
	# set player var for enemies spawned mid-game
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	while _player == null:
		await get_tree().process_frame
		if not is_instance_valid(self):
			return

	health.hurt.connect(func():
		sprite.stop()
		AiHelper.play_animation(sprite, "hurt", _dir)
	)
	health.died.connect(func():
		AiHelper.play_animation(sprite, "death", _dir)
		await sprite.animation_finished
		if not is_instance_valid(self):
			return

		if next_boss != null:
			var boss:CharacterBody2D = next_boss.instantiate()
			get_parent().add_child(boss)
			boss.global_position = global_position
		for i in range(death_slime_spawn_count):
			var s:CharacterBody2D = slime_enemy.instantiate()
			get_parent().add_child(s)
			var a = float(i)/death_slime_spawn_count * TAU
			var offset = Vector2(cos(a), sin(a))
			s.global_position = global_position + offset * 20

		queue_free()
	)

	# create states
	idle_state = State.new(
		"Idle",
		func():
		_face_player(),
		func(_delta):
		if not sprite.is_playing():
			AiHelper.play_animation(sprite, "idle", _dir)
		,
		func():
		_face_player()
	)
	jump_state = JumpState.new(self, 100, 1.0, sprite, attack_hitbox, false, func():
		_idle(between_states_wait_duration, func():
			shoot_state.shoot(global_position)
		)
	)
	shoot_state = ShootState.new(self, projectile, 4, false, func():
		_idle(between_states_wait_duration, func():
			jump_state.jump(_player.global_position)
		)
	)
	fsm = FSM.new(idle_state)

	await get_tree().process_frame
	if not is_instance_valid(self):
		return
	jump_state.jump(_player.global_position)


func _physics_process(delta:float) -> void:
	if not health.is_dead():
		if fsm != null:
			fsm.update(delta)
		move_and_slide()


func _face_player():
	var to_player = _player.global_position - global_position
	_dir = AiHelper.update_dir(to_player)


func _idle(duration:float, exit_idle:Callable):
	fsm.change_state(idle_state)
	await get_tree().create_timer(duration, false).timeout
	if not is_instance_valid(self):
		return
	exit_idle.call()

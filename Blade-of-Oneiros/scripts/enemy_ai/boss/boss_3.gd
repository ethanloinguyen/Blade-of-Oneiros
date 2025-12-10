class_name Boss_3
extends CharacterBody2D


@onready var attack_hitbox = $JumpHitbox
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var health:Health = $Health
@onready var audio = $AudioStreamPlayer2D

@export var between_states_wait_duration:float = 4.0

@export var texture_over:Texture2D

@export var bounce_audio: Array[AudioStream]
@export var death_audio: AudioStream
@export var hurt_audio: Array[AudioStream]

@export var projectile:PackedScene
@export var rain_slime:PackedScene

var fsm:FSM
var idle_state:State
var jump_state:JumpState
var rain_state:State
var shoot_state_1:ShootState
var shoot_state_2:ShootState
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
	
	
	#audio
	sprite.frame_changed.connect(func():
		if (sprite.animation.begins_with("death_down") or \
		sprite.animation.begins_with("death_up") or \
		sprite.animation.begins_with("death_left") or \
		sprite.animation.begins_with("death_right")) and sprite.frame == 1:
			play_audio(death_audio)
			
		if (sprite.animation.begins_with("hurt_down") or \
		sprite.animation.begins_with("hurt_up") or \
		sprite.animation.begins_with("hurt_left") or \
		sprite.animation.begins_with("hurt_right")):
			play_audio(hurt_audio[randi() % hurt_audio.size()])
	)

	AiHelper.connect_to_boss_health_bar(get_tree(), health, texture_over)
	health.hurt.connect(func():
		sprite.stop()
		AiHelper.play_animation(sprite, "hurt", _dir)
	)
	health.died.connect(func():
		AiHelper.play_animation(sprite, "death", _dir)
		$Shadow.queue_free()
		await sprite.animation_finished
		GameState.game_finished = true
		if not is_instance_valid(self):
			return
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
	jump_state = JumpState.new(self, 100, 0.7, sprite, attack_hitbox, true, func():
		play_audio(bounce_audio[randi() % bounce_audio.size()])
		fsm.change_state(rain_state)
	)
	rain_state = State.new(
		"Rain",
		func():
		for i in range(7):
			var rs:RainSlime = rain_slime.instantiate()
			get_parent().add_child(rs)
			rs.global_position = _player.global_position
			await get_tree().create_timer(0.2, false).timeout
			if not is_instance_valid(self):
				return
		await get_tree().create_timer(1.5, false).timeout
		if not is_instance_valid(self):
			return
		shoot_state_1.shoot(global_position)
		,
		func(_delta):
		pass
		,
		func():
		pass
	)
	shoot_state_1 = ShootState.new(self, projectile, 8, false, func():
		_idle(between_states_wait_duration, func():
			shoot_state_2.shoot(global_position)
		)
	)
	shoot_state_2 = ShootState.new(self, projectile, 8, true, func():
		_idle(5.0, func():
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
		

func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()


func _face_player():
	var to_player = _player.global_position - global_position
	_dir = AiHelper.update_dir(to_player)


func _idle(duration:float, exit_idle:Callable):
	fsm.change_state(idle_state)
	await get_tree().create_timer(duration, false).timeout
	if not is_instance_valid(self):
		return
	exit_idle.call()

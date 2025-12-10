class_name BombSlime
extends CharacterBody2D

@export var activate_distance:float
@export var speed:float
@export var move_avoid_collision_dist:float

@export var attack_distance:float
@export var start_jumping:bool
@export var jump_duration:float

@export var slime_attack_audio: AudioStream
@export var death_audio: AudioStream
@export var hurt_audio: Array[AudioStream]

@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var health:Health = $Health
@onready var explode_sprite:AnimatedSprite2D = $ExplodeSprite
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var fsm:FSM
var wait_state:State
var jump_state:JumpState
var chase_state:State
var explode_state:State


var _player:Player
var _dir:String = "down"


func _enter_tree():
	add_to_group("enemy")


func _ready():
	# set player var for enemies spawned mid-game
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	# health setup
	health.hurt.connect(func():
		fsm.change_state(explode_state)
	)

	#audio for death
	sprite.frame_changed.connect(func():
		if sprite.animation.begins_with("death") and sprite.frame == 1:
			play_audio(death_audio)

		if (sprite.animation.begins_with("hurt")):
			play_audio(hurt_audio[randi() % hurt_audio.size()])
	)

	# handle explosion
	sprite.animation_changed.connect(func():
		if sprite.animation.begins_with("explode"):
			await sprite.animation_finished
			explode_sprite.visible = true
			explode_sprite.play("explode")
			sprite.queue_free()
	)
	var explode_hitbox:Hitbox = explode_sprite.get_node("ExplodeHitbox")
	explode_hitbox.attach_signal(explode_sprite, false)

	# scale explosion sprite with animation progress
	var explosion_scale:float = explode_sprite.scale.x
	explode_sprite.frame_changed.connect(func():
		var frames := explode_sprite.sprite_frames.get_frame_count("explode")
		if frames <= 1:
			return

		var t:float = float(explode_sprite.frame) / float(frames - 1) # 0.0 at first frame, 1.0 at last frame
		var s:float = lerp(1.0, explosion_scale, t)
		explode_sprite.scale = Vector2.ONE * s
	)

	# create states
	wait_state = State.new(
		"Wait",
		Callable(),
		func(_delta:float):
			# wait until player variable is set
			if _player == null:
				return

			AiHelper.update_velocity_walk(self, Vector2.ZERO, [], 32)
			AiHelper.play_animation(sprite, "idle", _dir)

			# transition
			if _player.global_position.distance_to(global_position) < activate_distance:
				if start_jumping:
					jump_state.jump(_player.global_position)
				else:
					fsm.change_state(chase_state)
			,
		Callable(),
	)
	jump_state = JumpState.new(self, 60, jump_duration, sprite, null, false, func():
		fsm.change_state(chase_state)
		$Shadow.queue_free()
	)
	chase_state = State.new(
		"Chase",
		Callable(),
		func(_delta:float):
			var dist_to_player:float = _player.global_position.distance_to(global_position)
			var to_player:Vector2 = _player.global_position - global_position
			AiHelper.update_velocity_walk(self, to_player, [], 32)

			# play animation
			_dir = AiHelper.update_dir(to_player)
			if velocity.is_zero_approx():
				AiHelper.play_animation(sprite, "idle", _dir)
			else:
				AiHelper.play_animation(sprite, "walk", _dir)

			# transition
			if dist_to_player < attack_distance:
				fsm.change_state(explode_state)
			,
		Callable(),
	)
	explode_state = State.new(
		"Explode",
		func():
			if sprite == null or not is_instance_valid(sprite):
				return
			AiHelper.play_animation(sprite, "explode", _dir)
			var enemy_mask := 1 << 2
			collision_layer &= ~enemy_mask
			collision_mask &= ~enemy_mask
			#play_audio(slime_attack_audio)

			await explode_sprite.animation_finished
			queue_free()
			,
		func(_delta:float):
			velocity = Vector2.ZERO
			,
		Callable()
	)

	fsm = FSM.new(wait_state)

func _physics_process(delta:float) -> void:
	fsm.update(delta)
	move_and_slide()


func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()

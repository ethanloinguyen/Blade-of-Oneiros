class_name Enemy
extends CharacterBody2D

@export var activate_distance:float
@export var speed:float
@export var move_avoid_collision_dist:float
@export var chase_leash_distance:float

@export var attack_distance:float

@export var attack_audio: Array[AudioStream]
@export var death_audio: AudioStream
@export var hurt_audio: Array[AudioStream]

@onready var attack_hitbox = $AttackHitbox
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var health:Health = $Health
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var fsm:FSM
var wait_state:State
var chase_state:State
var attack_state:State
var stun_state:State
var _stun_knockback_dir:Vector2
var _stun_timer:float
const STUN_SPEED:float = 140.0

var _player:Player
var _dir:String = "down"


func _enter_tree():
	add_to_group("enemy")


func _ready():
	attack_hitbox.attach_signal(sprite, false)

	# set player var for enemies spawned mid-game
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	# health setup
	health.hurt.connect(func():
		fsm.change_state(stun_state)
	)
	health.died.connect(func():
		fsm.change_state(stun_state)
		AiHelper.play_animation(sprite, "death", _dir)
		$CollisionShape2D.disabled = true
		await sprite.animation_finished
		if not is_instance_valid(self):
			return
		queue_free()
	)

	#audio
	sprite.frame_changed.connect(func():
		if sprite.animation.begins_with("death") and sprite.frame == 1:
			play_audio(death_audio)
		
		if (sprite.animation.begins_with("hurt")):
			play_audio(hurt_audio[randi() % hurt_audio.size()])
		
		if (sprite.animation.begins_with("attack")) and sprite.frame == 4:
			play_audio(attack_audio[randi() % attack_audio.size()])
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
			fsm.change_state(chase_state)
		,
		Callable(),
	)
	chase_state = State.new(
		"Chase",
		Callable(),
		func(_delta:float):
		var dist_to_player:float = _player.global_position.distance_to(global_position)
		var to_player:Vector2 = _player.global_position - global_position
		var move_avoid_dirs:Array[Vector2] = []
		if chase_leash_distance > dist_to_player:
			move_avoid_dirs.push_back(to_player)
		AiHelper.update_velocity_walk(self, to_player, move_avoid_dirs, 32)

		# play animation
		_dir = AiHelper.update_dir(to_player)
		if velocity.is_zero_approx():
			AiHelper.play_animation(sprite, "idle", _dir)
		else:
			AiHelper.play_animation(sprite, "walk", _dir)

		# transition
		if dist_to_player < attack_distance:
			fsm.change_state(attack_state)
		,
		Callable(),
	)
	attack_state = State.new(
		"Attack",
		func():
		AiHelper.play_animation(sprite, "attack", _dir)
		#play_audio(slime_attack_audio)

		# wait for attack animation to finish
		await sprite.animation_finished
		
		if not is_instance_valid(self):
			return
		if fsm.current_state == attack_state:
			fsm.change_state(chase_state)
		,
		func(_delta:float):
		velocity = Vector2.ZERO
		,
		Callable()
	)
	stun_state = State.new(
		"Stun",
		func():
		sprite.stop()
		AiHelper.play_animation(sprite, "hurt", _dir)
		_stun_knockback_dir = global_position - _player.global_position
		_stun_timer = 0
		await sprite.animation_finished
		if not is_instance_valid(self):
			return
		fsm.change_state(chase_state)
		,
		func(delta):
		_stun_timer += delta
		if _stun_timer < 0.2:
			velocity = _stun_knockback_dir.normalized() * STUN_SPEED
		else:
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

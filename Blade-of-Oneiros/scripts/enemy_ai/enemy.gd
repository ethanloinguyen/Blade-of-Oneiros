class_name Enemy
extends CharacterBody2D

@export var activate_distance:float
@export var speed:float
@export var move_avoid_collision_dist:float
@export var chase_leash_distance:float

@export var attack_distance:float

@export var slime_attack_audio: AudioStream

@onready var attack_hitbox = $AttackHitbox
@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var health:Health = $Health
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var fsm:FSM
var wait_state:State
var chase_state:State
var attack_state:State
var stun_state:State

var _player:Player
var _dir:String = "down"

var MOVE_DIR_COUNT = 32
var _move_dirs:Array[Vector2]
var _move_dirs_weights:Array[float]
var _desired_move_dir:Vector2
var _move_avoid_dirs:Array[Vector2]


func _enter_tree():
	add_to_group("enemy")


func _ready():
	attack_hitbox.attach_signal(sprite, false)

	# set up movement
	for i in range(MOVE_DIR_COUNT):
		var angle = float(i)/MOVE_DIR_COUNT * TAU
		_move_dirs.push_back(Vector2(cos(angle), sin(angle)).normalized())
	_move_dirs_weights.resize(MOVE_DIR_COUNT)

	# set player var for enemies spawned mid-game
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	# health setup
	health.hurt.connect(func():
		fsm.change_state(stun_state)
	)
	health.died.connect(func():
		AiHelper.play_animation(sprite, "death", _dir)
		await sprite.animation_finished
		if not is_instance_valid(self):
			return
		queue_free()
	)

	# create states
	wait_state = State.new(
		"Wait",
		Callable(),
		func(_delta:float):
		# wait until player variable is set
		if _player == null:
			return

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
		var to_player = _player.global_position - global_position
		_desired_move_dir = to_player
		if chase_leash_distance > dist_to_player:
			_move_avoid_dirs.push_back(to_player)

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
		_desired_move_dir = Vector2.ZERO
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
		velocity = Vector2(0, 0)
		,
		Callable()
	)
	stun_state = State.new(
		"Stun",
		func():
		sprite.stop()
		AiHelper.play_animation(sprite, "hurt", _dir)
		await sprite.animation_finished
		if not is_instance_valid(self):
			return
		fsm.change_state(chase_state)
		,
		Callable()
		,
		Callable()
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	if not health.is_dead():
		fsm.update(delta)

		if not _desired_move_dir.is_zero_approx():
			_update_velocity()
			move_and_slide()


func _update_velocity() -> void:
	var space_state := get_world_2d().direct_space_state
	for i in range(_move_dirs.size()):
		_move_dirs_weights[i] = 1
	for i in range(_move_dirs.size()):
		# raycast to avoid collisions
		var query := PhysicsRayQueryParameters2D.create(global_position, global_position + _move_dirs[i] * move_avoid_collision_dist)
		query.collision_mask = collision_mask
		var result:Dictionary = space_state.intersect_ray(query)
		if result:
			var dist: float = global_position.distance_to(result["position"])

			# reduce weight of all nearby rays
			for j in range(_move_dirs.size()):
				var dp = _move_dirs[i].dot(_move_dirs[j])
				if dp > 0.3:
					var factor = dist/move_avoid_collision_dist * (1-dp)
					_move_dirs_weights[j] = min(_move_dirs_weights[j], factor)

		# avoid move_avoid_dirs
		for bad_dir in _move_avoid_dirs:
			if _move_dirs[i].dot(bad_dir) > 0.8:
				_move_dirs_weights[i] = 0

		# limit dirs based on desired_move_dir
		var dir_weighted_limit = max(_move_dirs[i].dot(_desired_move_dir.normalized()), 0)
		if _move_dirs_weights[i] > dir_weighted_limit:
			# weigh towards desired_move_dir
			_move_dirs_weights[i] = dir_weighted_limit
			# prefer rightward (clockwise) movement
			var desired_dir_right = Vector2(_desired_move_dir.y, -_desired_move_dir.x)
			var dp = _move_dirs[i].dot(desired_dir_right)
			if dp < -0.1 and _move_dirs_weights[i] > 0.3:
				_move_dirs_weights[i] = 0.3

	# set velocity
	var best_index = 0
	for i in range(_move_dirs_weights.size()):
		if _move_dirs_weights[i] > _move_dirs_weights[best_index]:
			best_index = i
	velocity = _move_dirs[best_index] * speed

	# reset move avoid dirs
	_move_avoid_dirs = []
	queue_redraw()
	
func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()


func _draw() -> void:
	if not OS.is_debug_build() or true:
		return

	# draw movement dir weights
	if _move_dirs_weights.size() == 0:
		return
	var best_index = 0
	for i in range(_move_dirs_weights.size()):
		if _move_dirs_weights[i] > _move_dirs_weights[best_index]:
			best_index = i
	for i in range(_move_dirs.size()):
		var color = Color(1, 0, 0)
		if i == best_index:
			color = Color(0, 1, 0)
		draw_line(Vector2.ZERO, _move_dirs[i] * _move_dirs_weights[i] * move_avoid_collision_dist, color, 1.0)

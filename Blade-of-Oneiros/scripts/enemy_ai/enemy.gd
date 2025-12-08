class_name Enemy
extends CharacterBody2D

@export var activate_distance:float
@export var speed:float
@export var chase_leash_distance:float

@export var attack_hitbox:Hitbox
@export var attack_distance:float

var fsm:FSM
var wait_state:State
var chase_state:State
var attack_state:State

var _player:TestPlayer


func _ready():
<<<<<<< Updated upstream
	_player = get_tree().get_first_node_in_group("player")
=======
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
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
		velocity = Vector2(0, 0)
		attack_hitbox.activate()
		,
		func(_delta:float):
		# TODO: wait for attack animation to finish
=======
		_desired_move_dir = Vector2.ZERO
		AiHelper.play_animation(sprite, "attack", _dir)

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
>>>>>>> Stashed changes
		fsm.change_state(chase_state)
		,
		Callable()
	)
	fsm = FSM.new(wait_state)


func _physics_process(delta:float) -> void:
	fsm.update(delta)
	move_and_slide()

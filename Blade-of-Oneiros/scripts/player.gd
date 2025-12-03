class_name Player
extends Character

@export var health:int = 100

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _damaged: bool = false
var _dead: bool = false

var move_cmd: Command
var attack_cmd: Command
var idle_cmd: Command

func _ready() -> void:
	animation_tree.active = true
	animation_player.speed_scale = 0.1
	bind_commands()

func _physics_process(delta: float) -> void:
	if _dead:
		return
	
	# if player isn't current attacking and pressed attack, then attack
	if attacking:
		super(delta)
		_manage_animation_tree_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		attack_cmd.execute(self)
		_manage_animation_tree_state()
		return
	
	if Input.is_action_pressed("run"):
		running = true
	else:
		running = false
	
	# Get player input direction
	direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	# Normalize diagonal movement speed
	if direction.length() > 1:
		direction = direction.normalized()
	
	# Reset velocity every frame
	velocity = Vector2.ZERO
	
	# If player input direction is not 0 execute 
	# appropriate movement command, if 0, execute idle
	if direction:
		move_cmd.execute(self)
	else:
		idle_cmd.execute(self)
	
	super(delta)
	
	_manage_animation_tree_state()


func take_damage(damage: int) -> void:
	health -= damage
	_damaged = true
	if health <= 0:
		# play death audio here
		_dead = true
		animation_tree.active = false
		animation_tree.play("death")
	else:
		# play hurt audio here
		pass


func bind_commands() -> void:
	move_cmd = MoveCommand.new()
	attack_cmd = AttackCommand.new()
	idle_cmd = IdleCommand.new()


func _manage_animation_tree_state() -> void:
	# Always update directional blend spaces
	if (direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
		animation_tree["parameters/run/blend_position"] = direction
		animation_tree["parameters/attack/blend_position"] = direction
		animation_tree["parameters/hurt/blend_position"] = direction
		animation_tree["parameters/death/blend_position"] = direction
	
	if (velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/moving"] = true
	
	# Toggles
	if attacking:
		animation_tree["parameters/conditions/attacking"] = true
		attacking = false
	else:
		animation_tree["parameters/conditions/attacking"] = false
		
	if _damaged:
		animation_tree["parameters/conditions/damaged"] = true
		_damaged = false
	else:
		animation_tree["parameters/conditions/damaged"] = false
		
	if running:
		animation_tree["parameters/conditions/running"] = true
	else:
		animation_tree["parameters/conditions/running"] = false

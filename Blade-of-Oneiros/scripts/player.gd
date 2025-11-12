class_name Player
extends Character

var move_cmd: Command
var attack_cmd: Command
var idle_cmd: Command

func _ready() -> void:
	bind_commands()

func _physics_process(delta: float) -> void:
	# if player isn't current attacking and pressed attack, then attack
	if attacking:
		super(delta)
		return
	
	if Input.is_action_just_pressed("attack"):
		attack_cmd.execute(self)
		return
		
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

func bind_commands() -> void:
	move_cmd = MoveCommand.new()
	attack_cmd = AttackCommand.new()
	idle_cmd = IdleCommand.new()


func _manage_animation_tree_state() -> void:
	pass

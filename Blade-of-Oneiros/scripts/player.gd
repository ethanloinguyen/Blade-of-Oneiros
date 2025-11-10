class_name Player
extends Character

var up_cmd: Command
var down_cmd: Command
var left_cmd: Command
var right_cmd: Command
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
	var dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	# Normalize diagonal movement speed
	if dir.length() > 1:
		dir = dir.normalized()
	
	# Reset velocity every frame
	velocity = Vector2.ZERO
	
	# If player input direction is not 0 execute 
	# appropriate movement command, if 0, execute idle
	if dir != Vector2.ZERO:
		if Input.is_action_pressed("run"):
			running = true
		else:
			running = false
		
		if abs(dir.x) > 0:
			if dir.x > 0:
				right_cmd.execute(self)
			else:
				left_cmd.execute(self)
		if abs(dir.y) > 0:
			if dir.y > 0:
				down_cmd.execute(self)
			else:
				up_cmd.execute(self)
		
		if running:
			play_animation("run")
		else:
			play_animation("walk")
	else:
		idle_cmd.execute(self)
		play_animation("idle")
	
	super(delta)
	
	_manage_animation_tree_state()

func bind_commands() -> void:
	up_cmd = MoveUpCommand.new()
	down_cmd = MoveDownCommand.new()
	left_cmd = MoveLeftCommand.new()
	right_cmd = MoveRightCommand.new()
	attack_cmd = AttackCommand.new()
	idle_cmd = IdleCommand.new()


func _manage_animation_tree_state() -> void:
	pass

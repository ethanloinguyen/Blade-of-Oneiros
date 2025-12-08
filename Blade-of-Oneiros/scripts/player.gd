class_name Player
extends Character

var move_cmd: Command
var attack_cmd: Command
var idle_cmd: Command
<<<<<<< Updated upstream

func _ready() -> void:
=======
var dash_cmd: Command
var facing_direction: Vector2 = Vector2.DOWN

var health_bar: TextureProgressBar
var stamina_bar: TextureProgressBar
var inventory: Control
#breaking/falling tile variables
var breakable_tiles: BreakableTiles
var falling: bool = false
var cutscene_scene: PackedScene = preload("res://scenes/falling_cutscene.tscn")
#Added by Alfred
var cutscene_walking: bool = false
var cutscene_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	#Added by Alfred
	process_mode = Node.PROCESS_MODE_ALWAYS

	animation_tree.active = true
	animation_player.speed_scale = 0.1
	
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()
		
	health_bar = hud.get_node("Health/HealthBar") as TextureProgressBar
	stamina_bar = hud.get_node("Stamina/StaminaBar") as TextureProgressBar
	inventory = hud.get_node("InventoryPanel") as Control
	hud.visible = true
	health.hurt.connect(_on_health_hurt)
	health.died.connect(_on_health_died)	
	health_bar.max_value = health.max_health
	set_health_bar()
	stamina_bar.max_value = max_stamina
	set_stamina_bar()
>>>>>>> Stashed changes
	bind_commands()

func _physics_process(delta: float) -> void:
	# ADDED BY ALFRED:
	# If the dialogue is active, the player should lose all movement, except idle.
	# However, the player should be able to move through durative commands (like exercise 1) for cutscenes.
	var in_dialogue := DialogueOrchestrator.is_dialogue_active()

<<<<<<< Updated upstream
	# if player isn't current attacking and pressed attack, then attack
	if attacking:
=======
	
	
	if dead:
		GameState.game_over = true
		#GameState.game_over = true
		#get_tree().change_scene_to_file("res://scenes/death_scene/death_screen.tscn")
		velocity = Vector2.ZERO
		return
	
	if falling:
		return
		
	# Regen stamina and update stamina bar
	_regen_stamina(delta)
	set_stamina_bar()
	
	if dash_on_cooldown:
		dash_cooldown_timer -= delta
		
		if dash_cooldown_timer <= 0:
			dash_on_cooldown = false
	
	# Handle attack lock (movement disabled)
	if attacking:
		attack_timer -= delta
		velocity = velocity * 0.25 
		
		# check unlock
		if attack_timer <= 0:
			attacking = false
		
		_manage_animation_tree_state()
		return
	
	# Handle dash lock (Adjusted by Alfred)
	if dashing and not in_dialogue:
		dash_timer -= delta
		dash_ghost_timer -= delta
		dash_time += delta / dash_duration

		
		var factor := dash_curve.sample(dash_time)
		velocity = dash_direction * dash_speed * factor
		if dash_ghost_timer <= 0.0:
			_spawn_dash_ghost()
			dash_ghost_timer = dash_ghost_interval
	
		if dash_timer <= 0:
			dashing = false
			dash_time = 0.0
			velocity = Vector2.ZERO
		
>>>>>>> Stashed changes
		super(delta)
		return
	
<<<<<<< Updated upstream
	if not in_dialogue and Input.is_action_just_pressed("attack"):
		attack_cmd.execute(self)
		return
		
	# Get player input direction (don't move when in dialogue)
	if not in_dialogue:
=======
	# If exhausted skip all stamina-related actions
	if not stamina_actions_locked:
		if Input.is_action_just_pressed("attack"):
			if try_use_stamina(stamina_cost_attack):
				#play_audio(sword_whoosh_audio[randi() % sword_whoosh_audio.size()])
				attack_cmd.execute(self)
				_manage_animation_tree_state()
				return
		
		# DASH (Adjusted by Alfred)
		if Input.is_action_just_pressed("dash") and not dash_on_cooldown and not in_dialogue:
			if try_use_stamina(stamina_cost_dash):
				dash_cmd.execute(self)
				dash_ghost_timer = 0.0
				_manage_animation_tree_state()
				return

	else:
		running = false
	
	# Get and normalize player direction (Adjusted by Alfred to fulfill Cutscene needs
	if not cutscene_walking:
>>>>>>> Stashed changes
		direction = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)
<<<<<<< Updated upstream
=======
		if direction.length() > 1:
			direction = direction.normalized()

>>>>>>> Stashed changes
	
	# Normalize diagonal movement speed
	if direction.length() > 1:
		direction = direction.normalized()
	
	# Reset velocity every frame
	velocity = Vector2.ZERO
	
	# If player input direction is not 0 execute 
<<<<<<< Updated upstream
	# appropriate movement command, if 0, execute idle
	if direction:
		move_cmd.execute(self)
	else:
		idle_cmd.execute(self)
=======
	# appropriate movement command, if 0, execute idle (Adjusted by Alfred)
	if not cutscene_walking:
		if direction:
			move_cmd.execute(self)
		else:
			idle_cmd.execute(self)

>>>>>>> Stashed changes
	
	super(delta)
	
	_manage_animation_tree_state()

<<<<<<< Updated upstream
=======

func take_damage(damage: int) -> void:
	health.take_damage(damage)
	
		
func _on_health_hurt() -> void:
	if dead:
		return
	_damaged = true
	set_health_bar()
	var sm: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	sm.travel("hurt") 

	#_manage_animation_tree_state()


func _on_health_died() -> void:
	if dead:
		return

	dead = true
	set_health_bar()

	attacking = false
	running = false
	velocity = Vector2.ZERO

	#animation_tree["parameters/conditions/death"] = true
	var sm: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	sm.travel("death")
	await get_tree().create_timer(1.0).timeout
	GameState.game_over = true
	get_tree().change_scene_to_file("res://scenes/death_scene/death_screen.tscn")
	#_manage_animation_tree_state()



# returns false if unable to use stamina, true if usable
func try_use_stamina(amount: float) -> bool:
	if stamina_actions_locked:
		return false # exhausted, cannot perform action
	
	# If stamina > 0, action is allowed EVEN IF amount > stamina
	if stamina > 0:
		stamina -= amount
		stamina = max(stamina, 0) # stamina should at least be 0
		stamina_delay_timer = stamina_recharge_delay 
		_check_exhaustion()
		return true
	
	return false

func set_health_bar() -> void:
	if health_bar and health:
		health_bar.value = health.current_health


func set_stamina_bar() -> void:
	if stamina_bar:
		stamina_bar.value = stamina


>>>>>>> Stashed changes
func bind_commands() -> void:
	move_cmd = MoveCommand.new()
	attack_cmd = AttackCommand.new()
	idle_cmd = IdleCommand.new()


func _manage_animation_tree_state() -> void:
<<<<<<< Updated upstream
	pass
=======
	# Always update directional blend spaces
	if dead:
		return
	if (direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
		animation_tree["parameters/run/blend_position"] = direction
		animation_tree["parameters/attack/blend_position"] = direction
		animation_tree["parameters/hurt/blend_position"] = direction
		animation_tree["parameters/death/blend_position"] = direction
	
	if (velocity == Vector2.ZERO) and not cutscene_walking: #Adjusted by Alfred
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/moving"] = true
	
	if stamina_actions_locked && running:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/moving"] = false
		animation_tree["parameters/conditions/running"] = false
	
	# Toggles
	animation_tree["parameters/conditions/attacking"] = attacking
		
	if _damaged:
		animation_tree["parameters/conditions/damaged"] = true
		_damaged = false
	else:
		animation_tree["parameters/conditions/damaged"] = false
		
	animation_tree["parameters/conditions/running"] = running
	if _damaged:
		animation_tree["parameters/conditions/damaged"] = true
		_damaged = false
	else:
		animation_tree["parameters/conditions/damaged"] = false
		
	animation_tree["parameters/conditions/running"] = running
# Added by Alfred
func begin_cutscene_walk(dir_str: String) -> void:
	cutscene_walking = true

	# Map text direction to a unit vector + facing enum
	match dir_str.to_lower():
		"left":
			cutscene_direction = Vector2.LEFT
			change_facing(Facing.LEFT)
		"right":
			cutscene_direction = Vector2.RIGHT
			change_facing(Facing.RIGHT)
		"up":
			cutscene_direction = Vector2.UP
			change_facing(Facing.UP)
		"down":
			cutscene_direction = Vector2.DOWN
			change_facing(Facing.DOWN)
		_:
			cutscene_direction = Vector2.ZERO

	# Use this direction for blend spaces
	if cutscene_direction != Vector2.ZERO:
		direction = cutscene_direction

	_manage_animation_tree_state()  # immediately update animations


func end_cutscene_walk() -> void:
	cutscene_walking = false
	cutscene_direction = Vector2.ZERO
	direction = Vector2.ZERO
	_manage_animation_tree_state()  # return to idle

## Inventory related commands:
#func _on_potion_pickup_area_entered(body):
	#if body is Player:
		#Inventory.add_potion(1)
		#queue_free()
#
#if Inventory.use_key():
	#open_door()
#else:
	#print("Need a key!")
#
#if Inventory.use_potion():
	#player.heal(20)
#else:
	#print("No potions!")
>>>>>>> Stashed changes

class_name Player
extends Character


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var push_ray: RayCast2D = $PushRay
@onready var hitbox: Hitbox = $HitBox
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var footstep_audio = $FootstepAudio2D
@onready var health: Health = $HurtBox
@export var attack_damage: int = 1
@export var hitbox_offset_down: Vector2 = Vector2(0, 0)
@export var hitbox_offset_up: Vector2 = Vector2(0, 8)
@export var hitbox_offset_right: Vector2 = Vector2(12, 10)
@export var hitbox_offset_left: Vector2 = Vector2(-12, 10)
@export var dash_ghost_scene: PackedScene
@export var dash_curve: Curve
@export var hurt_audio: Array[AudioStream] = []
@export var dash_audio: Array[AudioStream] = []
@export var attack_grunt_audio: Array[AudioStream] = []
@export var sword_whoosh_audio: Array[AudioStream] = []
@export var walking_audio: Array[AudioStream] = []
@export var running_audio: AudioStream
@export var falling_audio: AudioStream
@export var exhausted_audio: AudioStream
@export var death_audio: AudioStream


var dash_time:= 0.0
var _damaged: bool = false
var dead: bool = false
var attack_duration: float = 0.3  
var attack_timer: float = 0.0

# Dash related variables
var dash_duration: float = 0.16
var dash_timer: float = 0.0
var dash_ghost_interval:float = 0.03
var dash_ghost_timer: float = 0.0
var dash_on_cooldown: bool = true
var dash_cooldown: float = 0.8
var dash_cooldown_timer: float = 0.0
var dash_invuln_duration: float = 0.15
var dash_invuln_timer: float = 0.0

# STAMINA SYSTEM
var base_move_speed: float = 100.0
var slow_factor: float = 0.6
@export var max_stamina: float = 100.0
var stamina: float = 100.0

@export var stamina_recharge_rate: float = 20.0   # stamina per second
@export var stamina_recharge_delay: float = 1.0   # how long until refill starts
var stamina_delay_timer: float = 0.0
var stamina_actions_locked = false  # exhaustion state

@export var stamina_cost_attack: float = 10.0
@export var stamina_cost_dash: float = 15.0
@export var stamina_cost_run: float = 0.5

var move_cmd: Command
var attack_cmd: Command
var idle_cmd: Command
var dash_cmd: Command
var facing_direction: Vector2 = Vector2.DOWN

var health_bar: TextureProgressBar
var stamina_bar: TextureProgressBar
var inventory: Control
#breaking/falling tile variables
var breakable_tiles: BreakableTiles
var falling: bool = false
var cutscene_scene: PackedScene = preload("res://scenes/falling_cutscene.tscn")

var upgraded: bool = false
@export var upgraded_texture: Texture2D 

func _ready() -> void:

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
	bind_commands()
	
func _physics_process(delta: float) -> void:	

	stamina_bar.max_value = max_stamina
	set_stamina_bar()
	set_health_bar()
		


	#breakable_tiles = get_tree().current_scene.get_node("BreakableTiles")
	# ADDED BY ALFRED:
	# If the dialogue is active, the player should lose all movement, except idle.
	# However, the player should be able to move through durative commands (like exercise 1) for
	var in_dialogue := DialogueOrchestrator.is_dialogue_active()
	if not GameState.game_started or GameState.input_locked:
		velocity = Vector2.ZERO
		return
	
	# if in dialogue stop all movement
	if in_dialogue:
		return
	
	
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
	
	# Handle dash lock 
	if dashing:
		dash_invuln_timer -= delta
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
		
		if dash_invuln_timer <= 0:
			health.set_invincible(false)
		
		super(delta)
		_manage_animation_tree_state()
		return
	
	if Input.is_action_just_pressed("potion"):
		print("pressed")
		if Inventory.use_potion():
			print("heal")
			health.current_health += roundi(health.max_health * 0.2)
			health.current_health = min(health.max_health, health.current_health)
		_manage_animation_tree_state()
		return
	
	#if Input.is_action_just_pressed("use_key"):
		#if Inventory.use_key():
			## open door command
			#pass
		#_manage_animation_tree_state()
		#return
	
	# If exhausted skip all stamina-related actions
	if not stamina_actions_locked:
		if Input.is_action_just_pressed("attack"):
			if try_use_stamina(stamina_cost_attack):
				play_audio(sword_whoosh_audio[randi() % sword_whoosh_audio.size()])
				attack_cmd.execute(self)
				_manage_animation_tree_state()
				return
		
		# DASH
		if Input.is_action_just_pressed("dash") and not dash_on_cooldown:
			if try_use_stamina(stamina_cost_dash):
				play_audio(dash_audio[randi() % dash_audio.size()])
				dash_cmd.execute(self)
				dash_ghost_timer = 0.0
				_manage_animation_tree_state()
				return
	else:
		running = false
	
	# Get and normalize player direction
	direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if direction.length() > 1:
		direction = direction.normalized()
	
	#Ray updates in frame if while pressing directional input against box,
	# the ray collides with the box, it will continuously call push in that direction
	if direction != Vector2.ZERO:
		facing_direction = DirectionSnap._snap_to_cardinal(direction)
	
	if push_ray != null:
		var ray_length: float = 8
		push_ray.target_position = facing_direction * ray_length
		push_ray.force_raycast_update()
	
		if direction != Vector2.ZERO and push_ray.is_colliding():
			var collider_object: Object = push_ray.get_collider()
			if collider_object is PushableBox:
				var box: PushableBox = collider_object as PushableBox
				box.push(facing_direction)
	
	# Reset velocity every frame
	velocity = Vector2.ZERO
	
	# If player input direction is not 0 execute 
	# appropriate movement command, if 0, execute idle
	if direction:
		move_cmd.execute(self)
	else:
		idle_cmd.execute(self)
	
	super(delta)
	
	if breakable_tiles:
		breakable_tiles.process_player_step(global_position, self)
		
	_manage_animation_tree_state()

#function to play audio throughout script
func play_audio(_stream : AudioStream) -> void:
	audio.stream = _stream
	audio.play()
	
func play_footstep():
	footstep_audio.stream = walking_audio[randi() % walking_audio.size()]
	footstep_audio.pitch_scale = randf_range(0.95, 1.05)  
	footstep_audio.play()

func take_damage(damage: int) -> void:
	health.take_damage(damage)
		
func _on_health_hurt() -> void:
	if dead:
		return
	_damaged = true
	play_audio(hurt_audio[randi() % hurt_audio.size()])
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
	play_audio(death_audio)
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


func bind_commands() -> void:
	move_cmd = MoveCommand.new()
	attack_cmd = AttackCommand.new()
	idle_cmd = IdleCommand.new()
	dash_cmd = DashCommand.new()


# regen stamina when not full, unlock exhaustion when full
func _regen_stamina(delta):
	if stamina < max_stamina:
		if stamina_delay_timer > 0:
			stamina_delay_timer -= delta
		else:
			stamina += stamina_recharge_rate * delta
			stamina = min(stamina, max_stamina)
	
	stamina_bar.value = stamina
	
	# Unlock only when FULL
	if stamina_actions_locked and stamina >= max_stamina:
		stamina_actions_locked = false
		stamina_bar.modulate = Color(1, 1, 1)     # normal
		move_speed = base_move_speed


# if stamina reaches 0, lock stamina actions and slow player
func _check_exhaustion():
	if stamina <= 0 and not stamina_actions_locked:
		stamina_actions_locked = true
		running = false
		velocity = Vector2.ZERO
		stamina_bar.modulate = Color(1, 0.3, 0.3) # reddish
		move_speed = base_move_speed * slow_factor


func _spawn_dash_ghost() -> void:
	if dash_ghost_scene == null:
		return
	
	var ghost := dash_ghost_scene.instantiate() as Sprite2D
	var src: Sprite2D = $Sprite2D
	ghost.texture = src.texture
	ghost.hframes = src.hframes
	ghost.vframes = src.vframes
	ghost.frame = src.frame
	ghost.flip_h = src.flip_h
	ghost.flip_v = src.flip_v
	
	ghost.global_position = src.global_position
	ghost.global_rotation = src.global_rotation
	ghost.global_scale = src.global_scale
	
	get_tree().current_scene.add_child(ghost)


func upgrade_sprite() -> void:
	if upgraded:
		return
	
	upgraded = true
	sprite.texture = upgraded_texture
	
	# Upgrade player stats
	health.max_health = 200
	health_bar.max_value = health.max_health
	health.current_health = health.max_health
	stamina_recharge_rate = 30
	set_health_bar()
	set_stamina_bar()


#falling animation/ stops the player, plays moving animation, then fades the player
func start_fall(fall_position: Vector2) -> void:
	if falling or dead:
		return
		
	falling = true
	velocity = Vector2.ZERO
	running = false
	dashing = false
	attacking = false
	
	
	global_position = fall_position
	audio.stream = falling_audio
	audio.play()
	await get_tree().create_timer(0.2).timeout
	var fall_dir := direction
	if fall_dir == Vector2.ZERO:
		fall_dir = facing_direction
	animation_tree["parameters/idle/blend_position"] = fall_dir
	animation_tree["parameters/walk/blend_position"] = fall_dir
	animation_tree["parameters/run/blend_position"] = fall_dir
	animation_tree["parameters/attack/blend_position"] = fall_dir
	animation_tree["parameters/hurt/blend_position"] = fall_dir
	animation_tree["parameters/death/blend_position"] = fall_dir

	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/moving"] = true
	animation_tree["parameters/conditions/running"] = true
	animation_tree["parameters/conditions/attacking"] = false
	animation_tree["parameters/conditions/damaged"] = false
	await get_tree().create_timer(0.3).timeout
	
	var mat := sprite.material as ShaderMaterial
	
	var duration := 0.5
	var sink_amount := 5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "position:y", position.y + sink_amount, duration)

	if mat != null:
		tween.parallel().tween_property(mat, "shader_parameter/cut", 1.0, duration)

	await tween.finished
	if mat != null:
		mat.set_shader_parameter("cut", 1.0)
	modulate.a = 0.0
	
	var cutscene := cutscene_scene.instantiate() as FallingCutscene
	cutscene.player = self
	get_tree().current_scene.add_child(cutscene)
	var cam := get_node_or_null("Camera2D")
	if cam is Camera2D:
		(cam as Camera2D).enabled = false


func reset_player() -> void:
	dead = false
	falling = false
	attacking = false
	running = false
	velocity = Vector2.ZERO
	
	# Restore resources
	health.current_health = health.max_health
	stamina = max_stamina
	set_health_bar()
	set_stamina_bar()
	_manage_animation_tree_state()
	modulate = Color(1, 1, 1, 1)  # fully visible


func _manage_animation_tree_state() -> void:
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
	
	if (velocity == Vector2.ZERO):
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

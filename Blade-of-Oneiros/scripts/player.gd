class_name Player
extends Character

@export var health:int = 100

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var push_ray: RayCast2D = $PushRay
@onready var hitbox: Area2D = $HitBox
@onready var hitbox_collision: CollisionShape2D = $HitBox/CollisionShape2D

@export var attack_damage: int = 1
@export var hitbox_offset_down: Vector2 = Vector2(0, 0)
@export var hitbox_offset_up: Vector2 = Vector2(0, 8)
@export var hitbox_offset_right: Vector2 = Vector2(12, 10)
@export var hitbox_offset_left: Vector2 = Vector2(-12, 10)
@export var dash_ghost_scene: PackedScene
@export var dash_curve: Curve

var dash_time:= 0.0
var _damaged: bool = false
var _dead: bool = false
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

@onready var health_bar = $HUD/Health/HealthBar
@onready var stamina_bar = $HUD/Stamina/StaminaBar
@onready var inventory = $HUD/InventoryPanel

func _ready() -> void:
	print("Stamina bar is: ", stamina_bar)
	animation_tree.active = true
	animation_player.speed_scale = 0.1
	hitbox_collision.disabled = true
	stamina_bar.max_value = max_stamina
	set_stamina_bar()
	set_health_bar()
	bind_commands()


func _physics_process(delta: float) -> void:
	# ADDED BY ALFRED:
	# If the dialogue is active, the player should lose all movement, except idle.
	# However, the player should be able to move through durative commands (like exercise 1) for
	var in_dialogue := DialogueOrchestrator.is_dialogue_active()
	
	# if in dialogue stop all movement
	if in_dialogue:
		return
	
	if _dead:
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
			hitbox_collision.disabled = true
		
		_manage_animation_tree_state()
		return
	
	# Handle dash lock 
	if dashing:
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
		
		super(delta)
		_manage_animation_tree_state()
		return
	
	# If exhausted skip all stamina-related actions
	if not stamina_actions_locked:
		if Input.is_action_just_pressed("attack"):
			if try_use_stamina(stamina_cost_attack):
				attack_cmd.execute(self)
				_manage_animation_tree_state()
				return
		
		# DASH
		if Input.is_action_just_pressed("dash") and not dash_on_cooldown:
			if try_use_stamina(stamina_cost_dash):
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
	_update_hitbox()
	
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
	_manage_animation_tree_state()


func take_damage(damage: int) -> void:
	health -= damage
	set_health_bar()
	_damaged = true
	if health <= 0:
		# play death audio here
		_dead = true
		animation_tree.active = false
		animation_tree.play("death")
	else:
		# play hurt audio here
		pass


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
	health_bar.value = health

func set_stamina_bar() -> void:
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


func _update_hitbox() -> void:
	var rect := hitbox_collision.shape as RectangleShape2D
	if rect == null:
		return
	match facing_direction:
		Vector2.DOWN:
			hitbox.rotation = 0.0
			hitbox.position = hitbox_offset_down
	
		Vector2.RIGHT:
			hitbox.rotation = -PI * 0.5  
			hitbox.position = hitbox_offset_right
	
		Vector2.UP:
			hitbox.rotation = PI        
			hitbox.position = hitbox_offset_up
	
		Vector2.LEFT:
			hitbox.rotation = PI * 0.5 
			hitbox.position = hitbox_offset_left


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

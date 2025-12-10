extends Node

# Dash state 
var player: Character
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_ghost_timer := 0.0
var dash_time := 0.0

# Parameters 
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.8
@export var dash_ghost_interval: float = 0.03
@export var dash_curve: Curve
@export var dash_ghost_scene: PackedScene

var dash_on_cooldown := false
var dashing := false
var dash_direction := Vector2.ZERO


func attach_player(p: Character) -> void:
	player = p


func start_dash(p: Character) -> void:
	player = p
	if dashing or dash_cooldown_timer > 0:
		return

	# Determine dash direction
	if player.direction == Vector2.ZERO:
		dash_direction = player.facing_direction
	else:
		dash_direction = player.direction.normalized()

	# Begin dash
	dashing = true
	dash_on_cooldown = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_ghost_timer = 0.0
	dash_time = 0.0

	# Player invincibility
	player.health.set_invincible(true)


func process_dash(delta: float) -> void:
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	else: 
		dash_on_cooldown = false
	
	if not dashing:
		return
	
	dash_timer -= delta
	dash_ghost_timer -= delta
	dash_time += delta / dash_duration
	
	# Apply movement curve
	var factor := dash_curve.sample(dash_time)
	player.velocity = dash_direction * player.dash_speed * factor
	
	# Spawn ghosts
	if dash_ghost_timer <= 0:
		_spawn_ghost()
		dash_ghost_timer = dash_ghost_interval

	# End dash
	if dash_timer <= 0:
		dashing = false
		player.velocity = Vector2.ZERO
		player.health.set_invincible(false)


func _spawn_ghost() -> void:
	if not dash_ghost_scene:
		return

	var ghost := dash_ghost_scene.instantiate() as Sprite2D
	var src := player.sprite

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

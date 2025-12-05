class_name Character
extends CharacterBody2D

signal direction_changed(new_dir: int)

# --- Core movement parameters ---
@export var move_speed: float = 100.0
@export var run_speed: float = 170.0
@export var dash_speed: float = 2000.0

# --- Facing and state ---
enum Facing { UP, DOWN, LEFT, RIGHT }
var facing: Facing = Facing.DOWN
var direction: Vector2 = Vector2.ZERO
var current_state: String = "idle"
var attacking: bool = false
var running: bool = false
var dashing: bool = false
var dash_speed_factor: float = 0.0
# --- Animation ---
@onready var sprite: Sprite2D = $Sprite2D

# --- Movement handling ---
func _physics_process(_delta: float) -> void:
	move_and_slide()  # Base movement; subclasses or commands set velocity.

# Called by commands to set facing and trigger direction change signals.
func change_facing(new_facing: Facing) -> void:
	if facing != new_facing:
		facing = new_facing
		emit_signal("direction_changed", facing)

## Command helper for consistent animation naming.
#func play_animation(state: String) -> void:
	#var facing_name: String
	#match facing:
		#Facing.UP: facing_name = "up"
		#Facing.DOWN: facing_name = "down"
		#Facing.LEFT: facing_name = "left"
		#Facing.RIGHT: facing_name = "right"
		#_: facing_name = "down"
	#
	#var anim_name = "%s_%s" % [state, facing_name]  # e.g. walk_down
	#if anim_sprite.animation != anim_name:
		#anim_sprite.play(anim_name)
	#current_state = state

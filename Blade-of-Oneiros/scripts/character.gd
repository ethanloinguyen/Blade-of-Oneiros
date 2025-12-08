class_name Character
extends CharacterBody2D

signal direction_changed(new_dir: int)

# --- Core movement parameters ---
@export var move_speed: float = 100.0
@export var run_factor: float = 1.7
@export var dash_speed: float = 1400.0
# ADDED BY ALFRED: I need this to make sure oldmansmiles can move during in-game cutscenes
@export var character_id: String = ""

# --- Facing and state ---
enum Facing { UP, DOWN, LEFT, RIGHT }
var facing: Facing = Facing.DOWN
var dash_direction: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var current_state: String = "idle"
var attacking: bool = false
var running: bool = false
var dashing: bool = false
# --- Animation ---
@onready var sprite: Sprite2D = $Sprite2D

# ADDED BY ALFRED: I need this to make sure oldmansmiles can move during in-game cutscenes
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if character_id != "":
		set_meta("character_id", character_id)
	add_to_group("character")


# --- Movement handling ---
func _physics_process(_delta: float) -> void:
	move_and_slide()  # Base movement; subclasses or commands set velocity.

# Called by commands to set facing and trigger direction change signals.
func change_facing(new_facing: Facing) -> void:
	if facing != new_facing:
		facing = new_facing
		emit_signal("direction_changed", facing)
